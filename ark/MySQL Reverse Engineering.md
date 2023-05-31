# MySQL Reverse Engineering

이종수 팀장님께서 어느 정도 할 수 있는지 확인하기 위해 진욱씨가 직접 역공학을 해보는 방향으로 결정하셨습니다.

봐서 참고가 될 만한 문서들의 링크를 드리는 쪽으로 도움을 주시길 원하셔서 이 파일을 만들었습니다.

> [Oracle GoldenGate(MySQL Extract)](https://docs.oracle.com/en/middleware/goldengate/core/21.3/gghdb/using-oracle-goldengate-mysql.html)
>
> [mysqlbinlog](https://dev.mysql.com/doc/refman/8.0/en/mysqlbinlog.html)
>
> [MySQL C API Developer Guide](https://dev.mysql.com/doc/c-api/8.0/en/)
>
> [Github: mysql/mysql-server](https://github.com/mysql/mysql-server)

기본적으로 MySQL의 Binlog를 Extract하기 위한 최소 설정에 관한 내용이나 어떤 식의 정보가 추출되는지 확인을 Oracle GoldenGate를 참고하시면 도움이 되실 것 같습니다.

그 이후 MySQL에 내장되어 있는 `mysqlbinlog`를 실행시켜 Binlog에 어떤 내용들이 나오는 지 참고하시면 됩니다.

어느 정도 확인이 되신 후 MySQL C API Developer Guide를 확인해 `libmysqlclient.so` 파일을 링킹해 필요한 함수들을 어떻게 사용할 수 있는지 확인해보시고

마지막으로 Github에서 MySQL Server 소스 코드에서 내부 동작이 어떻게 돌아가는지 확인하시며 알아낸 내용, 분석한 값, 헤더, 데이터 등을 C로 추출해 내는 것이 목표입니다.

# MySQL Binlog Dump

프로젝트 설계를 한 후 개발하시면 됩니다.
입출력, 큰 흐름, 로직 등을 작성하시고 리뷰 받으신 후 개발을 진행하시면 됩니다.

개발할 때 [Jira Smart Commit](https://lab.idatabank.com/confluence/display/WIKIHOWTO/JIRA+Smart+Commit) 양식을 맞춰 작성하시는 것을 추천 드립니다.