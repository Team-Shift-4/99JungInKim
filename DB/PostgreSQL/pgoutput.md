위 문서는 PostgreSQL 11버전을 기반으로 작성되었다.

# PostgreSQL: pgoutput

```c
/*-------------------------------------------------------------------------
 *
 * pgoutput.c
 *		Logical Replication output plugin
 *
 * Copyright (c) 2012-2023, PostgreSQL Global Development Group
 *
 * IDENTIFICATION
 *		  src/backend/replication/pgoutput/pgoutput.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "access/tupconvert.h"
#include "catalog/partition.h"
#include "catalog/pg_publication.h"
#include "catalog/pg_publication_rel.h"
#include "catalog/pg_subscription.h"
#include "commands/defrem.h"
#include "commands/subscriptioncmds.h"
#include "executor/executor.h"
#include "fmgr.h"
#include "nodes/makefuncs.h"
#include "optimizer/optimizer.h"
#include "parser/parse_relation.h"
#include "replication/logical.h"
#include "replication/logicalproto.h"
#include "replication/origin.h"
#include "replication/pgoutput.h"
#include "utils/builtins.h"
#include "utils/inval.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/rel.h"
#include "utils/syscache.h"
#include "utils/varlena.h"

PG_MODULE_MAGIC;

static void pgoutput_startup(LogicalDecodingContext *ctx,
							 OutputPluginOptions *opt, bool is_init);
static void pgoutput_shutdown(LogicalDecodingContext *ctx);
static void pgoutput_begin_txn(LogicalDecodingContext *ctx,
							   ReorderBufferTXN *txn);
static void pgoutput_commit_txn(LogicalDecodingContext *ctx,
								ReorderBufferTXN *txn, XLogRecPtr commit_lsn);
static void pgoutput_change(LogicalDecodingContext *ctx,
							ReorderBufferTXN *txn, Relation relation,
							ReorderBufferChange *change);
static void pgoutput_truncate(LogicalDecodingContext *ctx,
							  ReorderBufferTXN *txn, int nrelations, Relation relations[],
							  ReorderBufferChange *change);
static void pgoutput_message(LogicalDecodingContext *ctx,
							 ReorderBufferTXN *txn, XLogRecPtr message_lsn,
							 bool transactional, const char *prefix,
							 Size sz, const char *message);
static bool pgoutput_origin_filter(LogicalDecodingContext *ctx,
								   RepOriginId origin_id);
static void pgoutput_begin_prepare_txn(LogicalDecodingContext *ctx,
									   ReorderBufferTXN *txn);
static void pgoutput_prepare_txn(LogicalDecodingContext *ctx,
								 ReorderBufferTXN *txn, XLogRecPtr prepare_lsn);
static void pgoutput_commit_prepared_txn(LogicalDecodingContext *ctx,
										 ReorderBufferTXN *txn, XLogRecPtr commit_lsn);
static void pgoutput_rollback_prepared_txn(LogicalDecodingContext *ctx,
										   ReorderBufferTXN *txn,
										   XLogRecPtr prepare_end_lsn,
										   TimestampTz prepare_time);
static void pgoutput_stream_start(struct LogicalDecodingContext *ctx,
								  ReorderBufferTXN *txn);
static void pgoutput_stream_stop(struct LogicalDecodingContext *ctx,
								 ReorderBufferTXN *txn);
static void pgoutput_stream_abort(struct LogicalDecodingContext *ctx,
								  ReorderBufferTXN *txn,
								  XLogRecPtr abort_lsn);
static void pgoutput_stream_commit(struct LogicalDecodingContext *ctx,
								   ReorderBufferTXN *txn,
								   XLogRecPtr commit_lsn);
static void pgoutput_stream_prepare_txn(LogicalDecodingContext *ctx,
										ReorderBufferTXN *txn, XLogRecPtr prepare_lsn);

static bool publications_valid;
static bool in_streaming;
static bool publish_no_origin;

static List *LoadPublications(List *pubnames);
static void publication_invalidation_cb(Datum arg, int cacheid,
										uint32 hashvalue);
static void send_relation_and_attrs(Relation relation, TransactionId xid,
									LogicalDecodingContext *ctx,
									Bitmapset *columns);
static void send_repl_origin(LogicalDecodingContext *ctx,
							 RepOriginId origin_id, XLogRecPtr origin_lsn,
							 bool send_origin);

/*
 * Only 3 publication actions are used for row filtering ("insert", "update",
 * "delete"). See RelationSyncEntry.exprstate[].
 */
enum RowFilterPubAction
{
	PUBACTION_INSERT,
	PUBACTION_UPDATE,
	PUBACTION_DELETE
};

#define NUM_ROWFILTER_PUBACTIONS (PUBACTION_DELETE+1)

/*
 * 맵의 항목은 보낸 관계 스키마를 기억하는 데 사용된다.
 *
 * schema_sent 플래그는 관계(publish_as_relid가 설정된 경우 조상에 대한 관계까지)에 대한 스키마 레코드가
 * 구독자에게 이미 전송된 여부를 결정한다(이 경우 다시 전송할 필요가 없다.).
 *
 * 다운스트림의 스키마 캐시는 커밋 시간에만 업데이트되며 스트리밍된 트랜잭션의 경우 커밋 순서가 트랜잭션이
 * 전송되는 순서와 다를 수 있다.
 * 또한 (하위)트랜잭션이 중단될 수 있으므로 중단 시 스키마 정보를 잃지 않도록 각 (하위)트랜잭션에 대한 스키마를
 * 보내야 한다.
 * 이를 처리하기 위해 이미 스키마를 보낸 xid(streamed_txns) 목록을 유지한다.
 * 
 * 파티션의 경우 'pubactions'은 테이블 자체 출판물뿐만 아니라 테이블의 모든 조상들의 출판물도 고려한다.
 */
typedef struct RelationSyncEntry
{
	Oid			relid;			/* 관계 객체 id */

	bool		replicate_valid;	/* 항목에 대한 전체 유효성 플래그 */

	bool		schema_sent;
	List	   *streamed_txns;	/* 이 스키마로 스트리밍된 최상위 트랜잭션 */

	/* are we publishing this rel? */
	PublicationActions pubactions;

	/*
	 * 행 필터에 대한 ExprState 배열이다.
	 * UPDATE나 DELETE는 식의 열을 복제 ID 색인의 일부로 제한하는 반면 INSERT에는 이 제한이 없다.
	 * 그러므로 게시 작업당 ExprState가 하나씩 존재하므로 다른 게시 작업은 여러 개의 식을 항상 하나로
	 * 결합할 수 없다.
	 */
	ExprState  *exprstate[NUM_ROWFILTER_PUBACTIONS];
	EState	   *estate;			/* 행 필터에 사용되는 실행기 상태 */
	TupleTableSlot *new_slot;	/* 새 튜플을 저장하는 슬롯 */
	TupleTableSlot *old_slot;	/* 이전 튜플을 저장하는 슬롯 */

	/*
	 * 게시할 관계의 객체 ID는 다음과 같이 변경된다.
	 * 파티션의 경우 게시에 대해 publish_via_partition_root가 설정되어 있는 경우 변경사항을
	 * 복제할 때 스키마가 사용될 상위 파티션 중 하나로 설정될 수 있다.
	 */
	Oid			publish_as_relid;

	/*
	 * 파티션의 유형에서 조상의 유형으로 튜플을 변환하기 위해 조상의 스키마를 사용해 복제할 때
	 * 사용되는 맵이다.
	 * publish_as_relid가 relid와 동일하거나 파티션 및 동일한 TupleDesc를 가진 조상으로 인해
	 * 불필요한 경우 NULL이다.
	 */
	AttrMap    *attrmap;

	/*
	 * 게시에 포함된 열이나 모든 열이 암시적으로 포함된 경우 NULL이다.
	 * 이 비트맵의 표시는 FirstLowInvalidHeapAttributeNumber만큼 이동되지 않는다.
	 */
	Bitmapset  *columns;

	/*
	 * 이 항목에 대한 추가 데이터를 저장할 개인 컨텍스트 - 행 필터식, 열 목록등에 대한 상태이다.
	 */
	MemoryContext entry_cxt;
} RelationSyncEntry;

/*
 * 트랜잭션 수준 별 변수를 유지해 트랜잭션이 BEGIN을 전송했는 지 여부를 추적한다.
 * BEGIN은 트랜잭션의 첫 번째 변경 사항이 처리될 때만 전송된다.
 * 이로 인해 빈 트랜잭션에 대한 BEGIN/COMMIT 메세지 쌍의 전송을 건너뛰어 네트워크 대역폭을 절약할 수 있다.
 *
 * 이 최적화는 준비된 트랜잭션에 사용되지 않는다.
 * 이유로는 만약 WALSender가 트랜잭션 준비 후나 동일한 트랜잭션을 준비한 커밋 전에 재시작된다면,
 * 빈 트랜잭션으로서 트랜잭션의 BEGIN/PREOARE 전송을 생략했는지를 알 수 없기 때문이다.
 * 이것은 재시작 전에 존재했던 메모리 내 txndata 정보를 손실했을 것이기 때문이다.
 * 다운스트림에서 대응하는 준비된 트랜잭션 없이 COMMIT PREPARED를 보낼 것이고 이를 처리할 때 오류가 발생한다.
 *
 * 다운스트림이 해당 준비가 전송되지 않았음을 감지할 수 있도록 프로토콜을 변경해 추가 정보를 전송함으로써
 * 이 최적화를 달성할 수 있다.
 * 그러나 다운스트림의 모든 트랜잭션에 대해 이런 검사를 추가하는 것은 비용이 많이 들 수 있으므로 선택적으로
 * 수행하는게 유리할 수 있다.
 *
 * 스트리밍된 트랜잭션은 준비된 트랜잭션을 포함할 수 있기 때문에 최적화하지 않았다.
 */
typedef struct PGOutputTxnData
{
	bool		sent_begin_txn; /* BEGIN이 전송되었는지 여부를 나타내는 플래그 */
} PGOutputTxnData;

/* 맵은 어떤 관계 스키마를 보냈는지 기억하는데 사용된다. */
static HTAB *RelationSyncCache = NULL;

static void init_rel_sync_cache(MemoryContext cachectx);
static void cleanup_rel_sync_cache(TransactionId xid, bool is_commit);
static RelationSyncEntry *get_rel_sync_entry(PGOutputData *data,
											 Relation relation);
static void rel_sync_cache_relation_cb(Datum arg, Oid relid);
static void rel_sync_cache_publication_cb(Datum arg, int cacheid,
										  uint32 hashvalue);
static void set_schema_sent_in_streamed_txn(RelationSyncEntry *entry,
											TransactionId xid);
static bool get_schema_sent_in_streamed_txn(RelationSyncEntry *entry,
											TransactionId xid);
static void init_tuple_slot(PGOutputData *data, Relation relation,
							RelationSyncEntry *entry);

/* 행 필터 루틴 */
static EState *create_estate_for_relation(Relation rel);
static void pgoutput_row_filter_init(PGOutputData *data,
									 List *publications,
									 RelationSyncEntry *entry);
static bool pgoutput_row_filter_exec_expr(ExprState *state,
										  ExprContext *econtext);
static bool pgoutput_row_filter(Relation relation, TupleTableSlot *old_slot,
								TupleTableSlot **new_slot_ptr,
								RelationSyncEntry *entry,
								ReorderBufferChangeType *action);

/* 열 목록 루틴 */
static void pgoutput_column_list_init(PGOutputData *data,
									  List *publications,
									  RelationSyncEntry *entry);

/*
 * 출력 플러그인 콜백 지정
 */
void
_PG_output_plugin_init(OutputPluginCallbacks *cb)
{
	cb->startup_cb = pgoutput_startup;
	cb->begin_cb = pgoutput_begin_txn;
	cb->change_cb = pgoutput_change;
	cb->truncate_cb = pgoutput_truncate;
	cb->message_cb = pgoutput_message;
	cb->commit_cb = pgoutput_commit_txn;

	cb->begin_prepare_cb = pgoutput_begin_prepare_txn;
	cb->prepare_cb = pgoutput_prepare_txn;
	cb->commit_prepared_cb = pgoutput_commit_prepared_txn;
	cb->rollback_prepared_cb = pgoutput_rollback_prepared_txn;
	cb->filter_by_origin_cb = pgoutput_origin_filter;
	cb->shutdown_cb = pgoutput_shutdown;

	/* 트랜잭션 스트리밍 */
	cb->stream_start_cb = pgoutput_stream_start;
	cb->stream_stop_cb = pgoutput_stream_stop;
	cb->stream_abort_cb = pgoutput_stream_abort;
	cb->stream_commit_cb = pgoutput_stream_commit;
	cb->stream_change_cb = pgoutput_change;
	cb->stream_message_cb = pgoutput_message;
	cb->stream_truncate_cb = pgoutput_truncate;
	/* 트랜잭션 스트리밍 - 2단계 COMMIT */
	cb->stream_prepare_cb = pgoutput_stream_prepare_txn;
}

static void
parse_output_parameters(List *options, PGOutputData *data)
{
	ListCell   *lc;
	bool		protocol_version_given = false;
	bool		publication_names_given = false;
	bool		binary_option_given = false;
	bool		messages_option_given = false;
	bool		streaming_given = false;
	bool		two_phase_option_given = false;
	bool		origin_option_given = false;

	data->binary = false;
	data->streaming = LOGICALREP_STREAM_OFF;
	data->messages = false;
	data->two_phase = false;

	foreach(lc, options)
	{
		DefElem    *defel = (DefElem *) lfirst(lc);

		Assert(defel->arg == NULL || IsA(defel->arg, String));

		/* 인식 여부와 상관없이 각 매개 변수를 확인한다. */
		if (strcmp(defel->defname, "proto_version") == 0)
		{
			unsigned long parsed;
			char	   *endptr;

			if (protocol_version_given)
				ereport(ERROR,
						(errcode(ERRCODE_SYNTAX_ERROR),
						 errmsg("conflicting or redundant options")));
			protocol_version_given = true;

			errno = 0;
			parsed = strtoul(strVal(defel->arg), &endptr, 10);
			if (errno != 0 || *endptr != '\0')
				ereport(ERROR,
						(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
						 errmsg("invalid proto_version")));

			if (parsed > PG_UINT32_MAX)
				ereport(ERROR,
						(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
						 errmsg("proto_version \"%s\" out of range",
								strVal(defel->arg))));

			data->protocol_version = (uint32) parsed;
		}
		else if (strcmp(defel->defname, "publication_names") == 0)
		{
			if (publication_names_given)
				ereport(ERROR,
						(errcode(ERRCODE_SYNTAX_ERROR),
						 errmsg("conflicting or redundant options")));
			publication_names_given = true;

			if (!SplitIdentifierString(strVal(defel->arg), ',',
									   &data->publication_names))
				ereport(ERROR,
						(errcode(ERRCODE_INVALID_NAME),
						 errmsg("invalid publication_names syntax")));
		}
		else if (strcmp(defel->defname, "binary") == 0)
		{
			if (binary_option_given)
				ereport(ERROR,
						(errcode(ERRCODE_SYNTAX_ERROR),
						 errmsg("conflicting or redundant options")));
			binary_option_given = true;

			data->binary = defGetBoolean(defel);
		}
		else if (strcmp(defel->defname, "messages") == 0)
		{
			if (messages_option_given)
				ereport(ERROR,
						(errcode(ERRCODE_SYNTAX_ERROR),
						 errmsg("conflicting or redundant options")));
			messages_option_given = true;

			data->messages = defGetBoolean(defel);
		}
		else if (strcmp(defel->defname, "streaming") == 0)
		{
			if (streaming_given)
				ereport(ERROR,
						(errcode(ERRCODE_SYNTAX_ERROR),
						 errmsg("conflicting or redundant options")));
			streaming_given = true;

			data->streaming = defGetStreamingMode(defel);
		}
		else if (strcmp(defel->defname, "two_phase") == 0)
		{
			if (two_phase_option_given)
				ereport(ERROR,
						(errcode(ERRCODE_SYNTAX_ERROR),
						 errmsg("conflicting or redundant options")));
			two_phase_option_given = true;

			data->two_phase = defGetBoolean(defel);
		}
		else if (strcmp(defel->defname, "origin") == 0)
		{
			if (origin_option_given)
				ereport(ERROR,
						errcode(ERRCODE_SYNTAX_ERROR),
						errmsg("conflicting or redundant options"));
			origin_option_given = true;

			data->origin = defGetString(defel);
			if (pg_strcasecmp(data->origin, LOGICALREP_ORIGIN_NONE) == 0)
				publish_no_origin = true;
			else if (pg_strcasecmp(data->origin, LOGICALREP_ORIGIN_ANY) == 0)
				publish_no_origin = false;
			else
				ereport(ERROR,
						errcode(ERRCODE_INVALID_PARAMETER_VALUE),
						errmsg("unrecognized origin value: \"%s\"", data->origin));
		}
		else
			elog(ERROR, "unrecognized pgoutput option: %s", defel->defname);
	}
}

/*
 * 플러그인 초기화
 */
static void
pgoutput_startup(LogicalDecodingContext *ctx, OutputPluginOptions *opt,
				 bool is_init)
{
	PGOutputData *data = palloc0(sizeof(PGOutputData));
	static bool publication_callback_registered = false;

	/* 개인 할당을 위한 메모리 컨텍스트를 생성 */
	data->context = AllocSetContextCreate(ctx->context,
										  "logical replication output context",
										  ALLOCSET_DEFAULT_SIZES);

	data->cachectx = AllocSetContextCreate(ctx->context,
										   "logical replication cache context",
										   ALLOCSET_DEFAULT_SIZES);

	ctx->output_plugin_private = data;

	/* 이 플러그인은 이진 프로토콜을 사용한다. */
	opt->output_type = OUTPUT_PLUGIN_BINARY_OUTPUT;

	/*
	 * 위는 복제 시작이며 슬롯 초기화가 되지 않았다.
	 *
	 * 클라이언트에서 전달한 옵션을 구문 분석하고 확인한다.
	 */
	if (!is_init)
	{
		/* 인식하지 못하는 것이 있으면 매개 변수를 구문 분석하고 오류를 발생한다. */
		parse_output_parameters(ctx->output_plugin_options, data);

		/* 요청된 프로토콜의 지원 유무를 확인한다. */
		if (data->protocol_version > LOGICALREP_PROTO_MAX_VERSION_NUM)
			ereport(ERROR,
					(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
					 errmsg("client sent proto_version=%d but server only supports protocol %d or lower",
							data->protocol_version, LOGICALREP_PROTO_MAX_VERSION_NUM)));

		if (data->protocol_version < LOGICALREP_PROTO_MIN_VERSION_NUM)
			ereport(ERROR,
					(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
					 errmsg("client sent proto_version=%d but server only supports protocol %d or higher",
							data->protocol_version, LOGICALREP_PROTO_MIN_VERSION_NUM)));

		if (data->publication_names == NIL)
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
					 errmsg("publication_names parameter missing")));

		/*
		 * 스트리밍 활성화 여부를 결정한다.
		 * 기본적으로 비활성화 되어 있으며, 이 경우 디코딩 컨텍스트에서 플래그를 업데이트 한다.
		 * 그렇지 않을 경우 충분한 버전의 프로토콜과 출력 플러그인이 지원하는 경우에만 허용한다.
		 */
		if (data->streaming == LOGICALREP_STREAM_OFF)
			ctx->streaming = false;
		else if (data->streaming == LOGICALREP_STREAM_ON &&
				 data->protocol_version < LOGICALREP_PROTO_STREAM_VERSION_NUM)
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
					 errmsg("requested proto_version=%d does not support streaming, need %d or higher",
							data->protocol_version, LOGICALREP_PROTO_STREAM_VERSION_NUM)));
		else if (data->streaming == LOGICALREP_STREAM_PARALLEL &&
				 data->protocol_version < LOGICALREP_PROTO_STREAM_PARALLEL_VERSION_NUM)
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
					 errmsg("requested proto_version=%d does not support parallel streaming, need %d or higher",
							data->protocol_version, LOGICALREP_PROTO_STREAM_PARALLEL_VERSION_NUM)));
		else if (!ctx->streaming)
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
					 errmsg("streaming requested, but not supported by output plugin")));

		/* 현재 어떤 트랜잭션도 스트리밍하고 있지 않다. */
		in_streaming = false;

		/*
		 * 여기서 2단계 옵션이 플러그인에 의해 통과되었는지 확인하고 나중에 그것을 활성화할지 여부를 결정한다.
		 * 이전 시작이 활성화되어 있다면 활성화된 상태로 유지된다.
		 * 충분한 버전의 프로토콜과 플러그인이 지원할 때에만 2단계 옵션이 전달되도록 허용한다.
		 */
		if (!data->two_phase)
			ctx->twophase_opt_given = false;
		else if (data->protocol_version < LOGICALREP_PROTO_TWOPHASE_VERSION_NUM)
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
					 errmsg("requested proto_version=%d does not support two-phase commit, need %d or higher",
							data->protocol_version, LOGICALREP_PROTO_TWOPHASE_VERSION_NUM)));
		else if (!ctx->twophase)
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
					 errmsg("two-phase commit requested, but not supported by output plugin")));
		else
			ctx->twophase_opt_given = true;

		/* 게시 상태 초기화 */
		data->publications = NIL;
		publications_valid = false;

		/*
		 * 프로세스에서 이전 호출 중 아직 호출되지 않은 경우 pg_publication에 콜백을 등록해야 한다.
		 */
		if (!publication_callback_registered)
		{
			CacheRegisterSyscacheCallback(PUBLICATIONOID,
										  publication_invalidation_cb,
										  (Datum) 0);
			publication_callback_registered = true;
		}

		/* 관계 스키마 캐시 초기홫 */
		init_rel_sync_cache(CacheMemoryContext);
	}
	else
	{
		/*
		 * 슬롯 초기화 모드 동안 스트리밍과 준비된 트랜잭션을 사용하지 않는다.
		 */
		ctx->streaming = false;
		ctx->twophase = false;
	}
}

/*
 * BEGIN 콜백이다.
 *
 * BEGIN을 발견하자마자 메세지를 보내지 않고 첫 번째 변경 사항이 있을 때 전송한다.
 * 논리적 복제에서 일반적인 시나리오는 테이블 집합을(전체 테이블 대신) 복제하는 것이고, 테이블에 변경 사항이
 * 있는 트랜잭션은 게시되지 않은 빈 트랜잭션을 생성한다.
 * 이러한 빈 트랜잭션은 논리적 복제에 거의 사용되지 않거나 사용되지 않는 것의 대역폭을 사용하여 구독자에게 
 * BEGIN과 COMMIT 메세지를 보낸다.
 */
static void
pgoutput_begin_txn(LogicalDecodingContext *ctx, ReorderBufferTXN *txn)
{
	PGOutputTxnData *txndata = MemoryContextAllocZero(ctx->context,
													  sizeof(PGOutputTxnData));

	txn->output_plugin_private = txndata;
}

/*
 * BEGIN을 보낸다.
 *
 * 첫 번째 변경 사항을 처리하는 동안 호출된다.
 */
static void
pgoutput_send_begin(LogicalDecodingContext *ctx, ReorderBufferTXN *txn)
{
	bool		send_replication_origin = txn->origin_id != InvalidRepOriginId;
	PGOutputTxnData *txndata = (PGOutputTxnData *) txn->output_plugin_private;

	Assert(txndata);
	Assert(!txndata->sent_begin_txn);

	OutputPluginPrepareWrite(ctx, !send_replication_origin);
	logicalrep_write_begin(ctx->out, txn);
	txndata->sent_begin_txn = true;

	send_repl_origin(ctx, txn->origin_id, txn->origin_lsn,
					 send_replication_origin);

	OutputPluginWrite(ctx, true);
}

/*
 * COMMIT 콜백
 */
static void
pgoutput_commit_txn(LogicalDecodingContext *ctx, ReorderBufferTXN *txn,
					XLogRecPtr commit_lsn)
{
	PGOutputTxnData *txndata = (PGOutputTxnData *) txn->output_plugin_private;
	bool		sent_begin_txn;

	Assert(txndata);

	/*
	 * 이 트랜잭션의 관련 변경 사항이 다운스트림의로 전송되지 않는 한 COMMIT 메세지를 보낼 필요가 없다.
	 */
	sent_begin_txn = txndata->sent_begin_txn;
	OutputPluginUpdateProgress(ctx, !sent_begin_txn);
	pfree(txndata);
	txn->output_plugin_private = NULL;

	if (!sent_begin_txn)
	{
		elog(DEBUG1, "skipped replication of an empty transaction with XID: %u", txn->xid);
		return;
	}

	OutputPluginPrepareWrite(ctx, true);
	logicalrep_write_commit(ctx->out, txn, commit_lsn);
	OutputPluginWrite(ctx, true);
}

/*
 * BEGIN PREPARE 콜백
 */
static void
pgoutput_begin_prepare_txn(LogicalDecodingContext *ctx, ReorderBufferTXN *txn)
{
	bool		send_replication_origin = txn->origin_id != InvalidRepOriginId;

	OutputPluginPrepareWrite(ctx, !send_replication_origin);
	logicalrep_write_begin_prepare(ctx->out, txn);

	send_repl_origin(ctx, txn->origin_id, txn->origin_lsn,
					 send_replication_origin);

	OutputPluginWrite(ctx, true);
}

/*
 * PREPARE 콜백
 */
static void
pgoutput_prepare_txn(LogicalDecodingContext *ctx, ReorderBufferTXN *txn,
					 XLogRecPtr prepare_lsn)
{
	OutputPluginUpdateProgress(ctx, false);

	OutputPluginPrepareWrite(ctx, true);
	logicalrep_write_prepare(ctx->out, txn, prepare_lsn);
	OutputPluginWrite(ctx, true);
}

/*
 * COMMIT PREPARED 콜백
 */
static void
pgoutput_commit_prepared_txn(LogicalDecodingContext *ctx, ReorderBufferTXN *txn,
							 XLogRecPtr commit_lsn)
{
	OutputPluginUpdateProgress(ctx, false);

	OutputPluginPrepareWrite(ctx, true);
	logicalrep_write_commit_prepared(ctx->out, txn, commit_lsn);
	OutputPluginWrite(ctx, true);
}

/*
 * ROLLBACK PREPARED 콜백
 */
static void
pgoutput_rollback_prepared_txn(LogicalDecodingContext *ctx,
							   ReorderBufferTXN *txn,
							   XLogRecPtr prepare_end_lsn,
							   TimestampTz prepare_time)
{
	OutputPluginUpdateProgress(ctx, false);

	OutputPluginPrepareWrite(ctx, true);
	logicalrep_write_rollback_prepared(ctx->out, txn, prepare_end_lsn,
									   prepare_time);
	OutputPluginWrite(ctx, true);
}

/*
 * 아직 완료되지 않은 경우 관계의 현재 스키마(조상이 있을 경우 조상까지)를 작성한다.
 */
static void
maybe_send_schema(LogicalDecodingContext *ctx,
				  ReorderBufferChange *change,
				  Relation relation, RelationSyncEntry *relentry)
{
	bool		schema_sent;
	TransactionId xid = InvalidTransactionId;
	TransactionId topxid = InvalidTransactionId;

	/*
	 * 변경을 위해 (하위)트랜잭션의 xid를 기억해야 한다.
	 * 최상위 트랜잭션인지의 유무는 상관없다(현재 스트리밍 블록 시작 시 해당 xid를 이미 보냈다.).
	 *
	 * 스트리밍 블록에 없는 경우 InvalidTransactionId를 사용하면 쓰기 메서드에 포함되지 않는다.
	 */
	if (in_streaming)
		xid = change->txn->xid;

	if (rbtxn_is_subtxn(change->txn))
		topxid = rbtxn_get_toptxn(change->txn)->xid;
	else
		topxid = xid;

	/*
	 * 스트리밍된 트랜잭션은 나중에 적용될 수도 있다.
	 * 나중에 적용될 때 까지 일반 트랜잭션은 효과를 보지 못하기 때문에 모르는 순서대로 개별적으로 추적한다.
	 *
	 * 항상 스트리밍 트랜잭션에서 스키마를 처음으로 보내지만 아마도 `relentry->schema_sent` 플래그를
	 * 선택하면 이를 피할 수 있다.
	 * 그러나 그러기 전 스트리밍 트랜잭션과 비스트리밍 트랜잭션이 혼재하는 경우에 스키마가 미치는 영향을
	 * 연구해야 한다.
	 */
	if (in_streaming)
		schema_sent = get_schema_sent_in_streamed_txn(relentry, topxid);
	else
		schema_sent = relentry->schema_sent;

	/* 이미 스키마를 보냈을 경우 할 일이 없다. */
	if (schema_sent)
		return;

	/*
	 * 스키마를 전송한다.
	 * 변경사항이 관계 자체가 아닌 조상의 스키마를 사용하여 게시될 경우 관계 자체를 보내기 전에 해당
	 * 조상의 스키마를 보낸다.
	 */
	if (relentry->publish_as_relid != RelationGetRelid(relation))
	{
		Relation	ancestor = RelationIdGetRelation(relentry->publish_as_relid);

		send_relation_and_attrs(ancestor, xid, ctx, relentry->columns);
		RelationClose(ancestor);
	}

	send_relation_and_attrs(relation, xid, ctx, relentry->columns);

	if (in_streaming)
		set_schema_sent_in_streamed_txn(relentry, topxid);
	else
		relentry->schema_sent = true;
}

/*
 * 관계 전송
 */
static void
send_relation_and_attrs(Relation relation, TransactionId xid,
						LogicalDecodingContext *ctx,
						Bitmapset *columns)
{
	TupleDesc	desc = RelationGetDescr(relation);
	int			i;

	/*
	 * 필요한 경우 유형 정보를 작성한다.
	 * 사용자가 작성한 유형에 대해서만 작성한다.
	 * FirstGenbkiObjectId를 컷오프로 사용하므로 예시로 information_schema에 정의한 함수나
	 * 유형이 아니라 직접 할당된 객체 ID를 가진 객체만 "built in"으로 간주한다.
	 * 이것은 직접 할당된 객체 ID만이 주요 버전에 걸쳐 안정적으로 유지할 수 있기 때문에 중요하다.
	 */
	for (i = 0; i < desc->natts; i++)
	{
		Form_pg_attribute att = TupleDescAttr(desc, i);

		if (att->attisdropped || att->attgenerated)
			continue;

		if (att->atttypid < FirstGenbkiObjectId)
			continue;

		/* 이 특성이 열 목록에 없는 경우 건너뛴다. */
		if (columns != NULL && !bms_is_member(att->attnum, columns))
			continue;

		OutputPluginPrepareWrite(ctx, false);
		logicalrep_write_typ(ctx->out, xid, att->atttypid);
		OutputPluginWrite(ctx, false);
	}

	OutputPluginPrepareWrite(ctx, false);
	logicalrep_write_rel(ctx->out, xid, relation, columns);
	OutputPluginWrite(ctx, false);
}

/*
 * 지정된 관계에 대한 행 필터 식의 평가를 위한 실행기 상태 준비이다.
 */
static EState *
create_estate_for_relation(Relation rel)
{
	EState	   *estate;
	RangeTblEntry *rte;
	List	   *perminfos = NIL;

	estate = CreateExecutorState();

	rte = makeNode(RangeTblEntry);
	rte->rtekind = RTE_RELATION;
	rte->relid = RelationGetRelid(rel);
	rte->relkind = rel->rd_rel->relkind;
	rte->rellockmode = AccessShareLock;

	addRTEPermissionInfo(&perminfos, rte);

	ExecInitRangeTable(estate, list_make1(rte), perminfos);

	estate->es_output_cid = GetCurrentCommandId(false);

	return estate;
}

/*
 * 행 필터를 평가한다.
 *
 * 행 필터가 NULL로 평가되면 잘못된 것으로 간주하고 변경 사항이 복제되지 않는다.
 */
static bool
pgoutput_row_filter_exec_expr(ExprState *state, ExprContext *econtext)
{
	Datum		ret;
	bool		isnull;

	Assert(state != NULL);

	ret = ExecEvalExprSwitchContext(state, econtext, &isnull);

	elog(DEBUG3, "row filter evaluates to %s (isnull: %s)",
		 isnull ? "false" : DatumGetBool(ret) ? "true" : "false",
		 isnull ? "true" : "false");

	if (isnull)
		return false;

	return DatumGetBool(ret);
}

/*
 * 항목별 메모리 컨텍스트가 있는지 확인한다.
 */
static void
pgoutput_ensure_entry_cxt(PGOutputData *data, RelationSyncEntry *entry)
{
	Relation	relation;

	/* bail out 케이스의 경우 컨텍스트가 이미 존재할 수 있다. */
	if (entry->entry_cxt)
		return;

	relation = RelationIdGetRelation(entry->publish_as_relid);

	entry->entry_cxt = AllocSetContextCreate(data->cachectx,
											 "entry private context",
											 ALLOCSET_SMALL_SIZES);

	MemoryContextCopyAndSetIdentifier(entry->entry_cxt,
									  RelationGetRelationName(relation));
}

/*
 * 행 필터를 초기화한다.
 */
static void
pgoutput_row_filter_init(PGOutputData *data, List *publications,
						 RelationSyncEntry *entry)
{
	ListCell   *lc;
	List	   *rfnodes[] = {NIL, NIL, NIL};	/* One per pubaction */
	bool		no_filter[] = {false, false, false};	/* One per pubaction */
	MemoryContext oldctx;
	int			idx;
	bool		has_filter = true;
	Oid			schemaid = get_rel_namespace(entry->publish_as_relid);

	/*
	 * 이 관계에 대한 행 필터가 있는지 찾는다.
	 * 만약 있을 경우 필요한 ExprState를 준비하고 entry->exprstate로 캐시한다.
	 * 식 상태를 만들기 위해 아래를 보장해야 한다.
	 *
	 * 1.	지정된 게시-테이블 매핑을 모두 선택해야 한다.
	 * 2.	다수의 게시물들은 이 관계에 대한 다수의 행 필터들을 가질 수 있다.
	 * 		행 필터 사용은 DML 동작에 의존하기에 행 필터들이 추가될 다수의 리스트들(각 동작당 하나)
	 * 		이 존재한다.
	 * 3.	모든 테이블과 스키마 테이블은 "행 필터 식을 사용하지 않음"을 의미하므로 우선한다.
	 */
	foreach(lc, publications)
	{
		Publication *pub = lfirst(lc);
		HeapTuple	rftuple = NULL;
		Datum		rfdatum = 0;
		bool		pub_no_filter = true;

		/*
		 * 게시가 FOR ALL TABLES거나 게시에 참조된 스키마에 속한 FOR TABLES IN SCHEMA를 포함하는
		 * 경우 다른 게시에 행 필터가 있는 경우에도 행 필터가 없는 것과 동일하게 취급된다.
		 */
		if (!pub->alltables &&
			!SearchSysCacheExists2(PUBLICATIONNAMESPACEMAP,
								   ObjectIdGetDatum(schemaid),
								   ObjectIdGetDatum(pub->oid)))
		{
			/*
			 * 이 게시에 행 필터가 있는지 확인한다.
			 */
			rftuple = SearchSysCache2(PUBLICATIONRELMAP,
									  ObjectIdGetDatum(entry->publish_as_relid),
									  ObjectIdGetDatum(pub->oid));

			if (HeapTupleIsValid(rftuple))
			{
				/* NULL은 행 필터가 없음을 나타낸다 */
				rfdatum = SysCacheGetAttr(PUBLICATIONRELMAP, rftuple,
										  Anum_pg_publication_rel_prqual,
										  &pub_no_filter);
			}
		}

		if (pub_no_filter)
		{
			if (rftuple)
				ReleaseSysCache(rftuple);

			no_filter[PUBACTION_INSERT] |= pub->pubactions.pubinsert;
			no_filter[PUBACTION_UPDATE] |= pub->pubactions.pubupdate;
			no_filter[PUBACTION_DELETE] |= pub->pubactions.pubdelete;

			/*
			 * 모든 DML 작업이 이 게시를 통해 게시되는 경우 빠른 종료를 한다.
			 */
			if (no_filter[PUBACTION_INSERT] &&
				no_filter[PUBACTION_UPDATE] &&
				no_filter[PUBACTION_DELETE])
			{
				has_filter = false;
				break;
			}

			/* 이 게시에 대한 추가 작업이 없다. */
			continue;
		}

		/* pubaction 행 필터 목록을 구성한다. */
		if (pub->pubactions.pubinsert && !no_filter[PUBACTION_INSERT])
			rfnodes[PUBACTION_INSERT] = lappend(rfnodes[PUBACTION_INSERT],
												TextDatumGetCString(rfdatum));
		if (pub->pubactions.pubupdate && !no_filter[PUBACTION_UPDATE])
			rfnodes[PUBACTION_UPDATE] = lappend(rfnodes[PUBACTION_UPDATE],
												TextDatumGetCString(rfdatum));
		if (pub->pubactions.pubdelete && !no_filter[PUBACTION_DELETE])
			rfnodes[PUBACTION_DELETE] = lappend(rfnodes[PUBACTION_DELETE],
												TextDatumGetCString(rfdatum));

		ReleaseSysCache(rftuple);
	}							/* 구독한 모든 게시를 반복한다. */

	/* 행 필터를 정리한다. */
	for (idx = 0; idx < NUM_ROWFILTER_PUBACTIONS; idx++)
	{
		if (no_filter[idx])
		{
			list_free_deep(rfnodes[idx]);
			rfnodes[idx] = NIL;
		}
	}

	if (has_filter)
	{
		Relation	relation = RelationIdGetRelation(entry->publish_as_relid);

		pgoutput_ensure_entry_cxt(data, entry);

		/*
		 * 모든 pubaction의 모든 필터를 알기 때문에 pubaction이 같을 때 결합한다.
		 */
		oldctx = MemoryContextSwitchTo(entry->entry_cxt);
		entry->estate = create_estate_for_relation(relation);
		for (idx = 0; idx < NUM_ROWFILTER_PUBACTIONS; idx++)
		{
			List	   *filters = NIL;
			Expr	   *rfnode;

			if (rfnodes[idx] == NIL)
				continue;

			foreach(lc, rfnodes[idx])
				filters = lappend(filters, stringToNode((char *) lfirst(lc)));

			/* 행 필터를 결합하고 ExprState를 캐시한다. */
			rfnode = make_orclause(filters);
			entry->exprstate[idx] = ExecPrepareExpr(rfnode, entry->estate);
		}						/* 각  */
		MemoryContextSwitchTo(oldctx);

		RelationClose(relation);
	}
}

/*
 * 열 목록을 초기화한다.
 */
static void
pgoutput_column_list_init(PGOutputData *data, List *publications,
						  RelationSyncEntry *entry)
{
	ListCell   *lc;
	bool		first = true;
	Relation	relation = RelationIdGetRelation(entry->publish_as_relid);

	/*
	 * 이 관계에 대한 열 목록이 있는지 찾는다.
	 * 열 목록이 있으면 열 목록을 사용해 비트맵을 작성한다.
	 *
	 * 여러 게시에 이 관계에 대한 열 목록이 여러 개 있을 수 있다.
	 *
	 * 게시들을 결합할 때 같은 표에 대해 열 목록이 다른 경우 지원하지 않는다.
	 * fetch_table_list 맨 위에 있는 주석을 참조하라.
	 * 나중에 게시를 변경할 수 있으므로 모든 게시-테이블 매핑을 확인하고 다른 열 목록을 가진 게시가 있으면 오류 반환한다.
	 */
	foreach(lc, publications)
	{
		Publication *pub = lfirst(lc);
		HeapTuple	cftuple = NULL;
		Datum		cfdatum = 0;
		Bitmapset  *cols = NULL;

		/*
		 * 게시가 모든 테이블을 위한 경우 열 목록이 없는 것과 동일하게 취급된다.
		 * (다른 게시에 목록이 있는 경우도 열 목록이 없는 것과 동일하게 취급된다.)
		 */
		if (!pub->alltables)
		{
			bool		pub_no_list = true;

			/*
			 * 게시에 열 목록이 있는지 확인한다.
			 *
			 * pg_publication_relow가 없으면 전체 스키마에 대해 정의된 게시이므로
			 * FOR ALL TABLES 게시와 마찬가지로 열 목록을 가질 수 없다.
			 */
			cftuple = SearchSysCache2(PUBLICATIONRELMAP,
									  ObjectIdGetDatum(entry->publish_as_relid),
									  ObjectIdGetDatum(pub->oid));

			if (HeapTupleIsValid(cftuple))
			{
				/* 열 목록 속성을 찾는다. */
				cfdatum = SysCacheGetAttr(PUBLICATIONRELMAP, cftuple,
										  Anum_pg_publication_rel_prattrs,
										  &pub_no_list);

				/* 항목별 컨텍스트에서 열 목록 비트맵을 작성한다. */
				if (!pub_no_list)	/* NULL이 아닐 경우 */
				{
					int			i;
					int			nliveatts = 0;
					TupleDesc	desc = RelationGetDescr(relation);

					pgoutput_ensure_entry_cxt(data, entry);

					cols = pub_collist_to_bitmapset(cols, cfdatum,
													entry->entry_cxt);

					/* 라이브 특성 수를 가져온다. */
					for (i = 0; i < desc->natts; i++)
					{
						Form_pg_attribute att = TupleDescAttr(desc, i);

						if (att->attisdropped || att->attgenerated)
							continue;

						nliveatts++;
					}

					/*
					 * 열 목록에 테이블의 모든 열이 포함된 경우 NULL로 설정한다.
					 */
					if (bms_num_members(cols) == nliveatts)
					{
						bms_free(cols);
						cols = NULL;
					}
				}

				ReleaseSysCache(cftuple);
			}
		}

		if (first)
		{
			entry->columns = cols;
			first = false;
		}
		else if (!bms_equal(entry->columns, cols))
			ereport(ERROR,
					errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
					errmsg("cannot use different column lists for table \"%s.%s\" in different publications",
						   get_namespace_name(RelationGetNamespace(relation)),
						   RelationGetRelationName(relation)));
	}							/* 구독한 모든 게시를 반복한다. */

	RelationClose(relation);
}

/*
 * 새 튜플과 이전 튜플을 저장하는 슬롯을 초기화하고 관계의 튜플을 조상의 형식으로 변환하는 데
 * 사용할 맵을 작성한다.
 */
static void
init_tuple_slot(PGOutputData *data, Relation relation,
				RelationSyncEntry *entry)
{
	MemoryContext oldctx;
	TupleDesc	oldtupdesc;
	TupleDesc	newtupdesc;

	oldctx = MemoryContextSwitchTo(data->cachectx);

	/*
	 * 튜플 테이블 슬롯을 생성한다.
	 * 캐시가 남아 있는 한 TupleDesc의 복사본을 생성한다.
	 */
	oldtupdesc = CreateTupleDescCopy(RelationGetDescr(relation));
	newtupdesc = CreateTupleDescCopy(RelationGetDescr(relation));

	entry->old_slot = MakeSingleTupleTableSlot(oldtupdesc, &TTSOpsHeapTuple);
	entry->new_slot = MakeSingleTupleTableSlot(newtupdesc, &TTSOpsHeapTuple);

	MemoryContextSwitchTo(oldctx);

	/*
	 * 필요한 경우 관계의 튜플을 상위 형식으로 변환하는 데 사용할 맵을 캐시한다.
	 */
	if (entry->publish_as_relid != RelationGetRelid(relation))
	{
		Relation	ancestor = RelationIdGetRelation(entry->publish_as_relid);
		TupleDesc	indesc = RelationGetDescr(relation);
		TupleDesc	outdesc = RelationGetDescr(ancestor);

		/* 맵은 세션만큼 수명이 길어야 한다. */
		oldctx = MemoryContextSwitchTo(CacheMemoryContext);

		entry->attrmap = build_attrmap_by_name_if_req(indesc, outdesc, false);

		MemoryContextSwitchTo(oldctx);
		RelationClose(ancestor);
	}
}

/*
 * 변경 사항이 있는 경우 행 필터에 대해 확인한다.
 *
 * 변경 사항을 복제할 경우 true를 반환하고 그렇지 않을 경우 false를 반환한다.
 *
 * INSERT의 경우 새 튜플에 대한 행 필터를 평가한다.
 * DELETE의 경우 오래된 튜플에 대한 행 필터를 평가한다.
 * UPDATE의 경우 기존과 새 튜플의 행 필터를 평가한다.
 *
 * 업데이트의 경우 두 평가가 모두 true면 UPDATE 전송을 허용하고 두 평가가 모두 false면 UPDATE를
 * 복제하지 않는다.
 * 두 개 중 하나만 행 필터 식과 일치하면 UPDATE를 DELETE나 INSERT로 변환해 다음 규칙에 따라
 * 데이터 불일치를 방지한다.
 * 1.	이전 행(no match)	새 행(no match)	-> CHNAGE DROP
 * 2.	이전 행(no match)	새 행(match)		-> INSERT	
 * 3.	이전 행(match)		새 행(no match)	-> DELETE
 * 4.	이전 행(match)		새 행(match)		-> UPDATE
 *
 * 새 작업이 작업 매개 변수에서 업데이트 된다.
 *
 * 원래 새 튜플에는 복제본 ID의 열 값이 없을 수 있으므로 UPDATE를 INSERT로 변환할 때 새 슬롯을
 * 업데이트 할 수 있다.
 * 
 * 이전의 튜플은 행 필터를 만족하나 새 튜플은 만족하지 않는다고 가정할 때 오래된 튜플이 만족하므로,
 * 초기 테이블 동기화는 이 행을 복사했다(또는 데이터 일관성이 있음을 보장하는 다른 방법이 사용되었다.).
 * 그러나 UPDATE 이후 새 튜플이 행 필터를 만족하지 않으므로 UPDATE 이후에는 새로운 튜플이 행 필터를
 * 만족하지 않으므로 데이터 일관성 관점에서 구독자에서 해당 행을 제거해야 한다.
 * UPDATE는 DELETE 문으로 변환되어 구독자에게 전송되어야 한다.
 * 구독자에게 이 행을 유지하는 것은 게시자의 행 필터식에 정의된 것을 반영하지 못하기 때문에 바람직하지 않다.
 * 구독자의 이 행은 복제에 의해 다시 수정되지 않을 가능성이 있다.
 * 만약 누군가가 동일한 오래된 식별자로 새로운 행을 삽입할 경우 제약조건 위반으로 복제가 중단될 수 있다.
 *
 * 이전의 튜플은 행 필터를 만족하지 않으나 새로운 튜플은 일치한다고 가정할 때 오래된 튜플이 만족하지 않으므로
 * 초기 테이블 동기화는 아마 이 행을 복사하지 않았을 것이다.
 * 그러나 UPDATE 이후에는 새로운 튜플이 행 필터를 만족하므로 데이터 일관섬 관점에서 구독자에게 해당 행을
 * INSERT 문으로 변환되어 구독자에게 전송해야 한다.
 * 그렇지 않으면 후속 UPDATE나 DELETE문은 아무런 영향을 미치지 못하기 때문이다.
 */
static bool
pgoutput_row_filter(Relation relation, TupleTableSlot *old_slot,
					TupleTableSlot **new_slot_ptr, RelationSyncEntry *entry,
					ReorderBufferChangeType *action)
{
	TupleDesc	desc;
	int			i;
	bool		old_matched,
				new_matched,
				result;
	TupleTableSlot *tmp_new_slot;
	TupleTableSlot *new_slot = *new_slot_ptr;
	ExprContext *ecxt;
	ExprState  *filter_exprstate;

	/*
	 * 이 맵은 특정 값을 가진 ReorderBufferChangeType 열거형에 의존하지 않기 위해 필요하다.
	 */
	static const int map_changetype_pubaction[] = {
		[REORDER_BUFFER_CHANGE_INSERT] = PUBACTION_INSERT,
		[REORDER_BUFFER_CHANGE_UPDATE] = PUBACTION_UPDATE,
		[REORDER_BUFFER_CHANGE_DELETE] = PUBACTION_DELETE
	};

	Assert(*action == REORDER_BUFFER_CHANGE_INSERT ||
		   *action == REORDER_BUFFER_CHANGE_UPDATE ||
		   *action == REORDER_BUFFER_CHANGE_DELETE);

	Assert(new_slot || old_slot);

	/* 해당 행 필터를 가져온다. */
	filter_exprstate = entry->exprstate[map_changetype_pubaction[*action]];

	/* 행 필터가 없는 경우 bail out */
	if (!filter_exprstate)
		return true;

	elog(DEBUG3, "table \"%s.%s\" has row filter",
		 get_namespace_name(RelationGetNamespace(relation)),
		 RelationGetRelationName(relation));

	ResetPerTupleExprContext(entry->estate);

	ecxt = GetPerTupleExprContext(entry->estate);

	/*
	 * 튜플이 하나밖에 없는 경우에는 해당 튜플에 대한 행 필터를 평가하고 반환할 수 있다.
	 *
	 * INSERT의 경우 새 튜플만 존재한다.
	 *
	 * UPDATE의 경우 복제본 ID 열이 변경되지 않고 외부 데이터가 없는 경우에만 새 튜플을 가질
	 * 수 있으나 해당 열의 기존 값이 필터와 일치하지 않을 수 있으므로 새 튜플에 대한 행 필터를
	 * 평가해야 한다.
	 * 또한 사용자는 행 필터에서 상수 식을 사용할 수 있으므로 새 튜플에 대한 평가가 필요하다.
	 *
	 * DELETE의 경우 전 튜플만 존재한다.
	 */
	if (!new_slot || !old_slot)
	{
		ecxt->ecxt_scantuple = new_slot ? new_slot : old_slot;
		result = pgoutput_row_filter_exec_expr(filter_exprstate, ecxt);

		return result;
	}

	/*
	 * 기존 튜플과 새 튜플은 모두 UPDATE에만 유효해야 하며 행 필터에서 확인해야 한다.
	 */
	Assert(map_changetype_pubaction[*action] == PUBACTION_UPDATE);

	slot_getallattrs(new_slot);
	slot_getallattrs(old_slot);

	tmp_new_slot = NULL;
	desc = RelationGetDescr(relation);

	/*
	 * 새 튜플에 모든 복제본 ID 열이 없을 수 있다.
	 * 이 경우 이전 튜플에서 복사해야 한다.
	 */
	for (i = 0; i < desc->natts; i++)
	{
		Form_pg_attribute att = TupleDescAttr(desc, i);

		/*
		 * 새 튜플이나 이전 튜플의 열이 NULL일 경우 할 일이 없다.
		 */
		if (new_slot->tts_isnull[i] || old_slot->tts_isnull[i])
			continue;

		/*
		 * 변경되지 않은 Toasted 복제본 ID 열은 이전 튜플에서만 기록되고 이를 새 튜플로 복사한다.
		 * 변경된(또는 WAL에 기록된) Toast 값은 항상 메모리에 조립되어 VARTAG_INDIRECT로
		 * 설정된다.
		 */
		if (att->attlen == -1 &&
			VARATT_IS_EXTERNAL_ONDISK(new_slot->tts_values[i]) &&
			!VARATT_IS_EXTERNAL_ONDISK(old_slot->tts_values[i]))
		{
			if (!tmp_new_slot)
			{
				tmp_new_slot = MakeSingleTupleTableSlot(desc, &TTSOpsVirtual);
				ExecClearTuple(tmp_new_slot);

				memcpy(tmp_new_slot->tts_values, new_slot->tts_values,
					   desc->natts * sizeof(Datum));
				memcpy(tmp_new_slot->tts_isnull, new_slot->tts_isnull,
					   desc->natts * sizeof(bool));
			}

			tmp_new_slot->tts_values[i] = old_slot->tts_values[i];
			tmp_new_slot->tts_isnull[i] = old_slot->tts_isnull[i];
		}
	}

	ecxt->ecxt_scantuple = old_slot;
	old_matched = pgoutput_row_filter_exec_expr(filter_exprstate, ecxt);

	if (tmp_new_slot)
	{
		ExecStoreVirtualTuple(tmp_new_slot);
		ecxt->ecxt_scantuple = tmp_new_slot;
	}
	else
		ecxt->ecxt_scantuple = new_slot;

	new_matched = pgoutput_row_filter_exec_expr(filter_exprstate, ecxt);

	/*
	 * 사례 1: 두 튜플이 모두 행 필터와 일치하지 않으면 bail out
	 * 아무것도 보내지 않는다.
	 */
	if (!old_matched && !new_matched)
		return false;

	/*
	 * 사례 2: 이전의 튜플이 행 필터를 만족하지 않으나 새 튜플이 만족하는 경우 UPDATE를 INSERT로 변환
	 * 
	 * 모든 복제 ID 열에 대한 열 값을 포함해야 하는 새로 변환된 튜플을 사용한다.
	 * 이것은 다운스트림 노드에 튜플을 삽입하는 동안 필요한 모든 열 값을 갖는 것을 보장하기 위해 요구된다.
	 */
	if (!old_matched && new_matched)
	{
		*action = REORDER_BUFFER_CHANGE_INSERT;

		if (tmp_new_slot)
			*new_slot_ptr = tmp_new_slot;
	}

	/*
	 * 사례 3: 이전의 튜플은 행 필터를 만족하나 새로운 튜플은 만족하지 않으면 UPDATE를 DELETE로 변환
	 *
	 * 이 변환에는 다른 튜플이 필요하지 않으며 이전 튜플은 DELETE에 사용된다.
	 */
	else if (old_matched && !new_matched)
		*action = REORDER_BUFFER_CHANGE_DELETE;

	/*
	 * 사례 4: 두 튜플이 모두 행 필터와 일치하는 경우 변환하지 않음
	 */

	return true;
}

/*
 * 디코딩된 DML을 전송한다.
 *
 * 스트리밍 모드와 비스트리밍 모드 모두 호출된다.
 */
static void
pgoutput_change(LogicalDecodingContext *ctx, ReorderBufferTXN *txn,
				Relation relation, ReorderBufferChange *change)
{
	PGOutputData *data = (PGOutputData *) ctx->output_plugin_private;
	PGOutputTxnData *txndata = (PGOutputTxnData *) txn->output_plugin_private;
	MemoryContext old;
	RelationSyncEntry *relentry;
	TransactionId xid = InvalidTransactionId;
	Relation	ancestor = NULL;
	Relation	targetrel = relation;
	ReorderBufferChangeType action = change->action;
	TupleTableSlot *old_slot = NULL;
	TupleTableSlot *new_slot = NULL;

	if (!is_publishable_relation(relation))
		return;

	/*
	 * 스트리밍 모드의 변경에 대한 xid를 기억해야 한다.
	 * 스트리밍 모드를 변경할 때마다 xid를 보내야 가입자들이 연결할 수 있고 중단될 때
	 * 해당 변경 사항을 폐기할 수 있다.
	 */
	if (in_streaming)
		xid = change->txn->xid;

	relentry = get_rel_sync_entry(data, relation);

	/* 테이블 필터를 확인한다. */
	switch (action)
	{
		case REORDER_BUFFER_CHANGE_INSERT:
			if (!relentry->pubactions.pubinsert)
				return;
			break;
		case REORDER_BUFFER_CHANGE_UPDATE:
			if (!relentry->pubactions.pubupdate)
				return;
			break;
		case REORDER_BUFFER_CHANGE_DELETE:
			if (!relentry->pubactions.pubdelete)
				return;

			/*
			 * 테이블에 대해 복제본 ID가 정의되지 않은 경우에도 삭제가 허용되는 경우에만 가능하다.
			 * DELETE 작업을 게시할 수 없으므로 반환하면 된다.
			 */
			if (!change->data.tp.oldtuple)
			{
				elog(DEBUG1, "didn't send DELETE change because of missing oldtuple");
				return;
			}
			break;
		default:
			Assert(false);
	}

	/* 자체 컨텍스트를 사용하고 재설정해 메모리 유출 방지 */
	old = MemoryContextSwitchTo(data->context);

	/* 루트를 통해 게시되는 경우 관계를 전환 */
	if (relentry->publish_as_relid != RelationGetRelid(relation))
	{
		Assert(relation->rd_rel->relispartition);
		ancestor = RelationIdGetRelation(relentry->publish_as_relid);
		targetrel = ancestor;
	}

	if (change->data.tp.oldtuple)
	{
		old_slot = relentry->old_slot;
		ExecStoreHeapTuple(&change->data.tp.oldtuple->tuple, old_slot, false);

		/* 필요할 시 튜플 변환 */
		if (relentry->attrmap)
		{
			TupleTableSlot *slot = MakeTupleTableSlot(RelationGetDescr(targetrel),
													  &TTSOpsVirtual);

			old_slot = execute_attr_map_slot(relentry->attrmap, old_slot, slot);
		}
	}

	if (change->data.tp.newtuple)
	{
		new_slot = relentry->new_slot;
		ExecStoreHeapTuple(&change->data.tp.newtuple->tuple, new_slot, false);

		/* Convert tuple if needed. */
		if (relentry->attrmap)
		{
			TupleTableSlot *slot = MakeTupleTableSlot(RelationGetDescr(targetrel),
													  &TTSOpsVirtual);

			new_slot = execute_attr_map_slot(relentry->attrmap, new_slot, slot);
		}
	}

	/*
	 * 행 필터를 확인한다.
	 *
	 * 전, 새 튜플에 대한 행 필터의 결과에 따라 UPDATE를 INSERT나 DELETE로 변환할 수 있다.
	 */
	if (!pgoutput_row_filter(targetrel, old_slot, &new_slot, relentry, &action))
		goto cleanup;

	/*
	 * 아직 전송하지 않은 경우 BEGIN을 전송한다.
	 * 변경 사항을 실제로 전송한 것을 보장한 후에 BEGIN 메세지를 전송한다.
	 * (빈 Transaction에 대한 BEGIN / COMMIT 메세지 쌍을 전송하지 않기 위해)
	 */
	if (txndata && !txndata->sent_begin_txn)
		pgoutput_send_begin(ctx, txn);

	/*
	 * 스키마는 상위 관계도 전송하므로 원래 관계를 사용하여 전송해야 한다.
	 */
	maybe_send_schema(ctx, change, relation, relentry);

	OutputPluginPrepareWrite(ctx, true);

	/* 데이터 전송 */
	switch (action)
	{
		case REORDER_BUFFER_CHANGE_INSERT:
			logicalrep_write_insert(ctx->out, xid, targetrel, new_slot,
									data->binary, relentry->columns);
			break;
		case REORDER_BUFFER_CHANGE_UPDATE:
			logicalrep_write_update(ctx->out, xid, targetrel, old_slot,
									new_slot, data->binary, relentry->columns);
			break;
		case REORDER_BUFFER_CHANGE_DELETE:
			logicalrep_write_delete(ctx->out, xid, targetrel, old_slot,
									data->binary, relentry->columns);
			break;
		default:
			Assert(false);
	}

	OutputPluginWrite(ctx, true);

cleanup:
	if (RelationIsValid(ancestor))
	{
		RelationClose(ancestor);
		ancestor = NULL;
	}

	MemoryContextSwitchTo(old);
	MemoryContextReset(data->context);
}

static void
pgoutput_truncate(LogicalDecodingContext *ctx, ReorderBufferTXN *txn,
				  int nrelations, Relation relations[], ReorderBufferChange *change)
{
	PGOutputData *data = (PGOutputData *) ctx->output_plugin_private;
	PGOutputTxnData *txndata = (PGOutputTxnData *) txn->output_plugin_private;
	MemoryContext old;
	RelationSyncEntry *relentry;
	int			i;
	int			nrelids;
	Oid		   *relids;
	TransactionId xid = InvalidTransactionId;

	/* 스트리밍 모드를 변경하려면 xid를 기억해야 한다. */
	if (in_streaming)
		xid = change->txn->xid;

	old = MemoryContextSwitchTo(data->context);

	relids = palloc0(nrelations * sizeof(Oid));
	nrelids = 0;

	for (i = 0; i < nrelations; i++)
	{
		Relation	relation = relations[i];
		Oid			relid = RelationGetRelid(relation);

		if (!is_publishable_relation(relation))
			continue;

		relentry = get_rel_sync_entry(data, relation);

		if (!relentry->pubactions.pubtruncate)
			continue;

		/*
		 * 게시에서 루트 테이블만 보내려면 파티션을 보내지 말아야 한다.
		 */
		if (relation->rd_rel->relispartition &&
			relentry->publish_as_relid != relid)
			continue;

		relids[nrelids++] = relid;

		/* 아직 전송하지 않은 경우 BEGIN을 전송한다. */
		if (txndata && !txndata->sent_begin_txn)
			pgoutput_send_begin(ctx, txn);

		maybe_send_schema(ctx, change, relation, relentry);
	}

	if (nrelids > 0)
	{
		OutputPluginPrepareWrite(ctx, true);
		logicalrep_write_truncate(ctx->out,
								  xid,
								  nrelids,
								  relids,
								  change->data.truncate.cascade,
								  change->data.truncate.restart_seqs);
		OutputPluginWrite(ctx, true);
	}

	MemoryContextSwitchTo(old);
	MemoryContextReset(data->context);
}

static void
pgoutput_message(LogicalDecodingContext *ctx, ReorderBufferTXN *txn,
				 XLogRecPtr message_lsn, bool transactional, const char *prefix, Size sz,
				 const char *message)
{
	PGOutputData *data = (PGOutputData *) ctx->output_plugin_private;
	TransactionId xid = InvalidTransactionId;

	if (!data->messages)
		return;

	/*
	 * 스트리밍 모드에서 메세지의 xid를 기억해야 한다.
	 */
	if (in_streaming)
		xid = txn->xid;

	/*
	 * 아직 출력하지 않은 경우 BEGIN을 출력한다.
	 * 트랜잭션이 아닌 메세지는 피한다.
	 */
	if (transactional)
	{
		PGOutputTxnData *txndata = (PGOutputTxnData *) txn->output_plugin_private;

		/* BEGIN을 전송하지 않은 경우 전송한다. */
		if (txndata && !txndata->sent_begin_txn)
			pgoutput_send_begin(ctx, txn);
	}

	OutputPluginPrepareWrite(ctx, true);
	logicalrep_write_message(ctx->out,
							 xid,
							 message_lsn,
							 transactional,
							 prefix,
							 sz,
							 message);
	OutputPluginWrite(ctx, true);
}

/*
 * 데이터가 원본과 연결되어 있고 사용자가 원본이 없는 변경을 요청한 경우 true,
 * 그렇지 않을 경우 false를 반환한다.
 */
static bool
pgoutput_origin_filter(LogicalDecodingContext *ctx,
					   RepOriginId origin_id)
{
	if (publish_no_origin && origin_id != InvalidRepOriginId)
		return true;

	return false;
}

/*
 * 출력 플러그인을 종료한다.
 *
 * data->context, data->cachectx는 하위 컨텍스트이므로 정리할 필요가 없다.
 */
static void
pgoutput_shutdown(LogicalDecodingContext *ctx)
{
	if (RelationSyncCache)
	{
		hash_destroy(RelationSyncCache);
		RelationSyncCache = NULL;
	}
}

/*
 * 게시 이름 목록에서 게시를 로드한다.
 */
static List *
LoadPublications(List *pubnames)
{
	List	   *result = NIL;
	ListCell   *lc;

	foreach(lc, pubnames)
	{
		char	   *pubname = (char *) lfirst(lc);
		Publication *pub = GetPublicationByName(pubname, false);

		result = lappend(result, pub);
	}

	return result;
}

/*
 * 게시 시스템 캐시 무효화 콜백이다.
 *
 * gp_publication에서 무효화를 요청한다.
 */
static void
publication_invalidation_cb(Datum arg, int cacheid, uint32 hashvalue)
{
	publications_valid = false;

	/*
	 * 관계별 캐시를 무효화하여 다음에 필터링 정보를 확인할 때 새 게시 설정으로 업데이트한다.
	 */
	rel_sync_cache_publication_cb(arg, cacheid, hashvalue);
}

/*
 * START STREAM 콜백
 */
static void
pgoutput_stream_start(struct LogicalDecodingContext *ctx,
					  ReorderBufferTXN *txn)
{
	bool		send_replication_origin = txn->origin_id != InvalidRepOriginId;

	/* we can't nest streaming of transactions */
	Assert(!in_streaming);

	/*
	 * 트랜잭션 스트리밍을 네스팅 할 수 없다.
	 */
	if (rbtxn_is_streamed(txn))
		send_replication_origin = false;

	OutputPluginPrepareWrite(ctx, !send_replication_origin);
	logicalrep_write_stream_start(ctx->out, txn->xid, !rbtxn_is_streamed(txn));

	send_repl_origin(ctx, txn->origin_id, InvalidXLogRecPtr,
					 send_replication_origin);

	OutputPluginWrite(ctx, true);

	/* 한 청크의 트랜잭션을 스트리밍 한다. */
	in_streaming = true;
}

/*
 * STOP STREAM 콜백
 */
static void
pgoutput_stream_stop(struct LogicalDecodingContext *ctx,
					 ReorderBufferTXN *txn)
{
	/* 트랜잭션을 스트리밍한다. */
	Assert(in_streaming);

	OutputPluginPrepareWrite(ctx, true);
	logicalrep_write_stream_stop(ctx->out);
	OutputPluginWrite(ctx, true);

	/* 트랜잭션 스트리밍을 중단한다. */
	in_streaming = false;
}

/*
 * 스트리밍된 트랜잭션(최상위 트랜잭션인 경우 모든 하위 트랜잭션과 함께)을 폐기하도록 다운스트림에 통지한다.
 */
static void
pgoutput_stream_abort(struct LogicalDecodingContext *ctx,
					  ReorderBufferTXN *txn,
					  XLogRecPtr abort_lsn)
{
	ReorderBufferTXN *toptxn;
	PGOutputData *data = (PGOutputData *) ctx->output_plugin_private;
	bool		write_abort_info = (data->streaming == LOGICALREP_STREAM_PARALLEL);

	/*
	 * 중단은 스트리밍된 트랜잭션에 대해 스트리밍 블록 외부에서 발생해야 한다.
	 * 하지만 트랜잭션은 스트리밍된 것으로 표시되어야 한다.
	 */
	Assert(!in_streaming);

	/* 최상위 트랜잭션을 결정한다. */
	toptxn = rbtxn_get_toptxn(txn);

	Assert(rbtxn_is_streamed(toptxn));

	OutputPluginPrepareWrite(ctx, true);
	logicalrep_write_stream_abort(ctx->out, toptxn->xid, txn->xid, abort_lsn,
								  txn->xact_time.abort_time, write_abort_info);

	OutputPluginWrite(ctx, true);

	cleanup_rel_sync_cache(toptxn->xid, false);
}

/*
 * 스트리밍된 트랜잭션(모든 하위 트랜잭션과 함께)을 적용하려면 다운스트림에 통지해야 한다.
 */
static void
pgoutput_stream_commit(struct LogicalDecodingContext *ctx,
					   ReorderBufferTXN *txn,
					   XLogRecPtr commit_lsn)
{
	/*
	 * 스트리밍된 트랜잭션에 대해서도 스트리밍 블록 외부에서 커밋이 발생해야 한다.
	 * 그러나 트랜잭션은 스트리밍된 것으로 표시되어야 한다.
	 */
	Assert(!in_streaming);
	Assert(rbtxn_is_streamed(txn));

	OutputPluginUpdateProgress(ctx, false);

	OutputPluginPrepareWrite(ctx, true);
	logicalrep_write_stream_commit(ctx->out, txn, commit_lsn);
	OutputPluginWrite(ctx, true);

	cleanup_rel_sync_cache(txn->xid, true);
}

/*
 * PREPARE 콜백 (2단계 커밋 스트리밍용).
 *
 * 트랜잭션을 준비하려면 다운스트림에 통지해야 한다.
 */
static void
pgoutput_stream_prepare_txn(LogicalDecodingContext *ctx,
							ReorderBufferTXN *txn,
							XLogRecPtr prepare_lsn)
{
	Assert(rbtxn_is_streamed(txn));

	OutputPluginUpdateProgress(ctx, false);
	OutputPluginPrepareWrite(ctx, true);
	logicalrep_write_stream_prepare(ctx->out, txn, prepare_lsn);
	OutputPluginWrite(ctx, true);
}

/*
 * 디코딩 세션에 대한 관계 스키마 동기화 캐시를 초기화한다.
 *
 * 해시 테이블은 디코딩 세션이 끝날 때 파괴된다.
 * relcache 무효화들이 여전히 존재하고 호출될 동안 그들은 NULL 해시 테이블을 글로벌하게 보고 어떤
 * 조치도 취하지 않는다.
 */
static void
init_rel_sync_cache(MemoryContext cachectx)
{
	HASHCTL		ctl;
	static bool relation_callbacks_registered = false;

	/* 해시 테이블이 이미 있는 경우 수행할 작업 없음 */
	if (RelationSyncCache != NULL)
		return;

	/* 캐시에 대한 새 해시 테이블 생성 */
	ctl.keysize = sizeof(Oid);
	ctl.entrysize = sizeof(RelationSyncEntry);
	ctl.hcxt = cachectx;

	RelationSyncCache = hash_create("logical replication output relation cache",
									128, &ctl,
									HASH_ELEM | HASH_CONTEXT | HASH_BLOBS);

	Assert(RelationSyncCache != NULL);

	/* 콜백을 등록한 경우 할 일이 없음 */
	if (relation_callbacks_registered)
		return;

	/* relcache 플러시 후 관계에 대한 캐시 항목을 업데이트해야 한다. */
	CacheRegisterRelcacheCallback(rel_sync_cache_relation_cb, (Datum) 0);

	/*
	 * 복제되는 관계에 영향을 미치는 스키마 이름 변경인 경우 pg_namespace 변경 후 모든 캐시 항목을 플러시한다.
	 */
	CacheRegisterSyscacheCallback(NAMESPACEOID,
								  rel_sync_cache_publication_cb,
								  (Datum) 0);

	/*
	 * 게시가 변경된 후 모든 캐시 항목을 플러시해야 한다.
	 * (pg_publication에 대한 콜백 항목은 필요 없다.
	   이유는 publication_invalidation_cb이 처리할 것이기 때문이다.)
	 */
	CacheRegisterSyscacheCallback(PUBLICATIONRELMAP,
								  rel_sync_cache_publication_cb,
								  (Datum) 0);
	CacheRegisterSyscacheCallback(PUBLICATIONNAMESPACEMAP,
								  rel_sync_cache_publication_cb,
								  (Datum) 0);

	relation_callbacks_registered = true;
}

/*
 * 스트리밍된 트랜잭션의 수가 상대적으로 적다.
 */
static bool
get_schema_sent_in_streamed_txn(RelationSyncEntry *entry, TransactionId xid)
{
	return list_member_xid(entry->streamed_txns, xid);
}

/*
 * 이미 관계 스키마를 보낸 rel sync 항목에 xid를 추가한다.
 */
static void
set_schema_sent_in_streamed_txn(RelationSyncEntry *entry, TransactionId xid)
{
	MemoryContext oldctx;

	oldctx = MemoryContextSwitchTo(CacheMemoryContext);

	entry->streamed_txns = lappend_xid(entry->streamed_txns, xid);

	MemoryContextSwitchTo(oldctx);
}

/*
 * 관계 스키마 캐시에서 항목을 찾거나 만든다.
 *
 * 주어진 관계가 직간접적으로(실제 관계의 조상이 출판물의 일부인 경우 후자인 경우) 출판물을 검색하고 발견된
 * 항목을 게시할 작업과 게시 시 조상의 스키마 사용 여부에 대한 정보로 채운다.
 */
static RelationSyncEntry *
get_rel_sync_entry(PGOutputData *data, Relation relation)
{
	RelationSyncEntry *entry;
	bool		found;
	MemoryContext oldctx;
	Oid			relid = RelationGetRelid(relation);

	Assert(RelationSyncCache != NULL);

	/* 캐시된 관계 정보를 찾는다. 찾을 수 없을 경우 생성한다. */
	entry = (RelationSyncEntry *) hash_search(RelationSyncCache,
											  &relid,
											  HASH_ENTER, &found);
	Assert(entry != NULL);

	/* 새 항목인 경우 초기화 */
	if (!found)
	{
		entry->replicate_valid = false;
		entry->schema_sent = false;
		entry->streamed_txns = NIL;
		entry->pubactions.pubinsert = entry->pubactions.pubupdate =
			entry->pubactions.pubdelete = entry->pubactions.pubtruncate = false;
		entry->new_slot = NULL;
		entry->old_slot = NULL;
		memset(entry->exprstate, 0, sizeof(entry->exprstate));
		entry->entry_cxt = NULL;
		entry->publish_as_relid = InvalidOid;
		entry->columns = NULL;
		entry->attrmap = NULL;
	}

	/* 항목 유효성 확인 */
	if (!entry->replicate_valid)
	{
		Oid			schemaId = get_rel_namespace(relid);
		List	   *pubids = GetRelationPublications(relid);

		/*
		 * 기록 스냅샷을 사용하여 캐시 항목을 구축하고 WAL을 디코딩하는 동안 이후의 모든 변경 사항이
		 * 흡수되므로 네임스페이스 시스템 테이블에 대한 잠금을 획득하지 않습니다.
		 */
		List	   *schemaPubids = GetSchemaPublications(schemaId);
		ListCell   *lc;
		Oid			publish_as_relid = relid;
		int			publish_ancestor_level = 0;
		bool		am_partition = get_rel_relispartition(relid);
		char		relkind = get_rel_relkind(relid);
		List	   *rel_publications = NIL;

		/* 필요한 경우 사용 전에 게시를 다시 로드한다. */
		if (!publications_valid)
		{
			oldctx = MemoryContextSwitchTo(CacheMemoryContext);
			if (data->publications)
			{
				list_free_deep(data->publications);
				data->publications = NIL;
			}
			data->publications = LoadPublications(data->publication_names);
			MemoryContextSwitchTo(oldctx);
			publications_valid = true;
		}

		/*
		 * 관계 정의가 변경되었을 수 있으므로 schema_sent 상태를 재설정한다.
		 * 또한 게시에서 rel이 삭제된 경우 pubactions를 empty로 재설정한다.
		 * 또한 이전 정의에 의존했던 모든 객체를 해제한다.
		 */
		entry->schema_sent = false;
		list_free(entry->streamed_txns);
		entry->streamed_txns = NIL;
		bms_free(entry->columns);
		entry->columns = NULL;
		entry->pubactions.pubinsert = false;
		entry->pubactions.pubupdate = false;
		entry->pubactions.pubdelete = false;
		entry->pubactions.pubtruncate = false;

		/*
		 * 튜플 슬롯이 정리된다(필요한 경우 나중에 다시 작성된다.).
		 */
		if (entry->old_slot)
			ExecDropSingleTupleTableSlot(entry->old_slot);
		if (entry->new_slot)
			ExecDropSingleTupleTableSlot(entry->new_slot);

		entry->old_slot = NULL;
		entry->new_slot = NULL;

		if (entry->attrmap)
			free_attrmap(entry->attrmap);
		entry->attrmap = NULL;

		/*
		 * 행필터 캐시가 정리된다.
		 */
		if (entry->entry_cxt)
			MemoryContextDelete(entry->entry_cxt);

		entry->entry_cxt = NULL;
		entry->estate = NULL;
		memset(entry->exprstate, 0, sizeof(entry->exprstate));

		/*
		 * 게시 캐시를 구축한다.
		 * relcache는 주어진 관계에 있는 모든 게시를 고려하기에 relcache에서 제공하는 것을
		 * 사용할 수 없으나 구독자가 요청한 게시만 고려하면 된다.
		 */
		foreach(lc, data->publications)
		{
			Publication *pub = lfirst(lc);
			bool		publish = false;

			/*
			 * 게시의 변경사항을 어떤 신뢰도 아래에서 게시해야 하는지 설정
			 * 이 게시의 상위 등급을 추적한다.
			 */
			Oid			pub_relid = relid;
			int			ancestor_level = 0;

			/*
			 * FOR ALL TABLES 게시인 경우 파티션 루트를 선택하고 그에 따라 상위 수준을 설정한다. 
			 */
			if (pub->alltables)
			{
				publish = true;
				if (pub->pubviaroot && am_partition)
				{
					List	   *ancestors = get_partition_ancestors(relid);

					pub_relid = llast_oid(ancestors);
					ancestor_level = list_length(ancestors);
				}
			}

			if (!publish)
			{
				bool		ancestor_published = false;

				/*
				 * 파티션의 경우 상위 항목이 게시되었는지 확인한다.
				 * 만약 그렇다면 파티션 변경 내용을 게시하는데 사용되는 이 게시물을 통해 게시된
				 * 최상위 항목을 기록한다.
				 */
				if (am_partition)
				{
					Oid			ancestor;
					int			level;
					List	   *ancestors = get_partition_ancestors(relid);

					ancestor = GetTopMostAncestorInPublication(pub->oid,
															   ancestors,
															   &level);

					if (ancestor != InvalidOid)
					{
						ancestor_published = true;
						if (pub->pubviaroot)
						{
							pub_relid = ancestor;
							ancestor_level = level;
						}
					}
				}

				if (list_member_oid(pubids, pub->oid) ||
					list_member_oid(schemaPubids, pub->oid) ||
					ancestor_published)
					publish = true;
			}

			/*
			 * 관계를 게시할 경우 게시할 작업을 결정하고 해당하는 경우 열 목록을 나열한다.
			 *
             * 파티션된 테이블에 대한 변경사항을 게시하지 말아야 한다.
             * pubviroot 설정으로 인해 파티션 변경 사항이 게시되지 않는 한 파티션을 게시하면 충분하기 때문이다.
			 */
			if (publish &&
				(relkind != RELKIND_PARTITIONED_TABLE || pub->pubviaroot))
			{
				entry->pubactions.pubinsert |= pub->pubactions.pubinsert;
				entry->pubactions.pubupdate |= pub->pubactions.pubupdate;
				entry->pubactions.pubdelete |= pub->pubactions.pubdelete;
				entry->pubactions.pubtruncate |= pub->pubactions.pubtruncate;

				/*
				 * 모든 게시에 걸쳐 변경 사항을 최상위 조상으로 게시하려 한다.
				 * 이미 계산된 수준이 새로운 수준보다 높은지 확인해야 한다.
				 * 만약 계산된 수준이 새로운 수준보다 높다면 자식이기에 새로운 값을 무시할 수 있다.
				 * 그렇지 않다면 새로운 값이 조상이므로 유지한다.
				 */
				if (publish_ancestor_level > ancestor_level)
					continue;

				/*
				 * 트리 위에서 조상을 발견할 시 복제하는 게시 목록을 버리고 조상을 사용한다.
				 */
				if (publish_ancestor_level < ancestor_level)
				{
					publish_as_relid = pub_relid;
					publish_ancestor_level = ancestor_level;

					/* 이 관계에 대한 게시 목록 재설정 */
					rel_publications = NIL;
				}
				else
				{
					/* 동일한 상위 수준, 동일한 객체 ID여야 한다. */
					Assert(publish_as_relid == pub_relid);
				}

				/* 상위 항목에 대한 게시를 추적한다. */
				rel_publications = lappend(rel_publications, pub);
			}
		}

		entry->publish_as_relid = publish_as_relid;

		/*
		 * 튜플 슬롯, 맵, 행 필터를 초기화한다.
		 * INSERT, UPDATE, DELETE를 게시할 때만 사용된다.
		 */
		if (entry->pubactions.pubinsert || entry->pubactions.pubupdate ||
			entry->pubactions.pubdelete)
		{
			/* 튜플 슬롯과 맵 초기화 */
			init_tuple_slot(data, relation, entry);

			/* 행 필터 초기화 */
			pgoutput_row_filter_init(data, rel_publications, entry);

			/* 열 목록 초기화 */
			pgoutput_column_list_init(data, rel_publications, entry);
		}

		list_free(pubids);
		list_free(schemaPubids);
		list_free(rel_publications);

		entry->replicate_valid = true;
	}

	return entry;
}

/*
 * 스트리밍된 트랜잭션 목록을 정리하고 schema_sent 플래그를 업데이트 한다.
 *
 * 스트리밍된 트랜잭션이 커밋되거나 중단될 때 스키마 캐시에서 최상위 xid를 제거해야 한다.
 * 트랜잭션이 중단되면 구독자는 스트리밍한 스키마 레코드를 그냥 버리기에 다른 작업을 할 필요가 없다.
 *
 * 트랜잭션이 커밋되면 구독자가 관계 캐시를 업데이트하므로 schema_sent 플래그를 적절히 조정한다.
 */
static void
cleanup_rel_sync_cache(TransactionId xid, bool is_commit)
{
	HASH_SEQ_STATUS hash_seq;
	RelationSyncEntry *entry;
	ListCell   *lc;

	Assert(RelationSyncCache != NULL);

	hash_seq_init(&hash_seq, RelationSyncCache);
	while ((entry = hash_seq_search(&hash_seq)) != NULL)
	{
		/*
		 * 목록에서 xid를 커밋한 항목에 대해 schema_sent 플래그를 설정하여 가입자가 해당 스키마를 가질 수
		 * 있도록 하고 해당 관계에 대한 무효화가 없는 한 보낼 필요가 없다.
		 */
		foreach(lc, entry->streamed_txns)
		{
			if (xid == lfirst_xid(lc))
			{
				if (is_commit)
					entry->schema_sent = true;

				entry->streamed_txns =
					foreach_delete_current(entry->streamed_txns, lc);
				break;
			}
		}
	}
}

/*
 * Relcache 무효화 콜백
 */
static void
rel_sync_cache_relation_cb(Datum arg, Oid relid)
{
	RelationSyncEntry *entry;

	/*
	 * 디코딩이 완료되면 RelSchemaSyncCache가 파기되므로 SQL 인터페이스에서 플러그인을 사용했다면
	 * 여기에 도달할 수 있으나 RelCache 무효화 콜백 등록을 취소할 순 없다.
	 */
	if (RelationSyncCache == NULL)
		return;

	/*
	 * 외부 논리 디코딩 콜백 호출 주변에 이 해시 테이블의 항목에 대한 포인터를 유지하지 않는다.
	 * 그러나 콜백에서 시스템 캐시 접근을 수행하면 콜백 중에 무효화 이벤트가 발생할 수 있다.
	 * 그 때문에 캐시 항목을 무효로 표시해야 하나 하위구조를 손상시키지 말아야 한다.
	 * 다음 get_rel_sync_entry() 호출은 이 모든 것을 재구축할 것이다.
	 */
	if (OidIsValid(relid))
	{
		/*
		 * 테이블에 없는 관계에 대해 무효화를 받는 것은 정상적이다.
		 * 발견이 돼도, 되지 않아도 상관 없다.
		 */
		entry = (RelationSyncEntry *) hash_search(RelationSyncCache, &relid,
												  HASH_FIND, NULL);
		if (entry != NULL)
			entry->replicate_valid = false;
	}
	else
	{
		/* 전체 캐시를 플러시한다. */
		HASH_SEQ_STATUS status;

		hash_seq_init(&status, RelationSyncCache);
		while ((entry = (RelationSyncEntry *) hash_seq_search(&status)) != NULL)
		{
			entry->replicate_valid = false;
		}
	}
}

/*
 * 게시 관계 / 스키마 맵 syscache 무효화 콜백
 *
 * pg_publication, pg_publication_rel, pg_publication_namespace, pg_namespace에 대해 무효화를 요청한다.
 */
static void
rel_sync_cache_publication_cb(Datum arg, int cacheid, uint32 hashvalue)
{
	HASH_SEQ_STATUS status;
	RelationSyncEntry *entry;

	/*
	 * 디코딩이 완료되면 RelSchemaSyncCache가 파기되므로 SQL 인터페이스에서 플러그인을 사용했다면
	 * 여기에 도달할 수 있으나 무효화 콜백의 등록을 취소할 순 없다.
	 */
	if (RelationSyncCache == NULL)
		return;

	/*
	 * 이 무효화 이벤트가 영향을 미쳤을 수 있는 캐시 항목을 쉽게 식별할 수 있는 방법이 없으므로 모두 무효로 표시한다.
	 */
	hash_seq_init(&status, RelationSyncCache);
	while ((entry = (RelationSyncEntry *) hash_seq_search(&status)) != NULL)
	{
		entry->replicate_valid = false;
	}
}

/* 복제 원본 전송 */
static void
send_repl_origin(LogicalDecodingContext *ctx, RepOriginId origin_id,
				 XLogRecPtr origin_lsn, bool send_origin)
{
	if (send_origin)
	{
		char	   *origin;

		/*----------
		 * XXX: 여기서 어떤 행동을 원하는가?
		 *
		 * 대안:
		 *  - 원본 이름을 찾을 수 없는 경우 원본 메세지를 보내지 않음(현재)
		 *  - 에러 발생 - 복제가 중단됨
		 *  - 알 수 없는 원본을 전송
		 *----------
		 */
		if (replorigin_by_oid(origin_id, true, &origin))
		{
			/* 경계 메세지 */
			OutputPluginWrite(ctx, false);
			OutputPluginPrepareWrite(ctx, true);

			logicalrep_write_origin(ctx->out, origin, origin_lsn);
		}
	}
}
```

