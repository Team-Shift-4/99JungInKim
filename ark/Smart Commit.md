# Smart Commit

- JIRA는 `code commit`시 입력한 `commit message`를 분석해 일감 상태를 업데이트 해줍니다.
    - JIRA 프로젝트에 코드 관리 시스템이 연동되어 있어야 합니다.

# 방법

1. 작업한 내용을 `commit` 할 때 `commit message`에 해당 작업의 일감 번호를 적습니다.
2. 일감 업데이트 할 내용을 작성합니다. (`Smart Commit Command`)
    1. `comment`: 일감에 댓글을 답니다.
    2. `time`: 일감에 작업 시간을 기록합니다.
    3. `transition`: 일감의 사태를 변경합니다.
3. 기타 부가적인 기능 (추후 기록)
- 위와 같이 작성하면 JIRA가 `smart commit`이라고 판단하여 `commit message`를 해석합니다.
- `Smart Commit Command`의 순서는 상관 없으나 `command` 입력 전에 일감 번호가 나와야 합니다.

# 구문

## Basic Structure

```
<ignored text> ISSUE_KEY <ignored text> #<command> <command argument (optional)>
```

- `ignored text`: JIRA는 `commit message`에서 일감 번호와 `Smart Commit Command`, `command`에 
따른 `argument`만 인식하고 나머지 text는 무시합니다.

## Command

### Comment

```
<ignored text> ISSUE_KEY <ignored text> #comment <comment_string>
```

- ex) CDCDEVLOP-234 #comment send 모듈 수정 완료, recv 모듈 수정이 필요합니다.

| ISSUE_KEY | #comment | comment_string |
| --- | --- | --- |
| CDCDEVELOP-234 | #comment | send 모듈 수정 완료, recv 모듈 수정이 필요합니다. |

### time

```
<ignored text> ISSUE_KEY <ignored text> #time <value>w <value>d <value>h <value>m <comment_string>
```

- `w`, `d`, `h`, `m`: 주, 일, 시, 분
- ex) CDCDEVELOP-234 #time 3h send / recv ssl 적용

| ISSUE_KEY | #time | <value>[w, d, h, m] | comment_string |
| --- | --- | --- | --- |
| CDCDEVELOP-234 | #time | 3h | send / recv ssl 적용 |

### transition

```
<ignored text> ISSUE_KEY <ignored text> #<transition_name> <comment_string>
```

<aside>
⭐ `transition_name`

일감의 작업 흐름을 참조해 작성하면 됩니다.

![시스템의 `버그` 유형과 작업 흐름](./Smart Commit/Untitled.png)

시스템의 `버그` 유형과 작업 흐름

 `transition_name`은 상태 변경 화살표 위에 문구중 하나입니다.

만약 여러 단어로 구성된 경우 `-` 기호를 사용하면 됩니다.

- ex) Start Progress: `#start-progress`

중복되는 케이스가 없을 시 일부 단어만 사용해도 됩니다.

- ex) Start Process: `#start`, `~~#progress~~`(`#progress`는 Stop Progress에 중복)

대소문자 구분은 없으며 권한이 없는 상태로의 전이는 추후 체크 후 작성하겠습니다.

![시스템의 `작업` 유형](./Smart Commit/Untitled%201.png)

시스템의 `작업` 유형

위와 같이 특정 흐름에 대한 정의가 없는 경우 변경하려는 상태의 이름을 작성하면 됩니다.

ex) TO DO: `#to-do`, IN PROGRESS: `#in-progress` 등

</aside>

- ex) CDCDEVELOP-234 #resolve row chaining 관련 추출 로직 에러. 관련 내용 수정하였습니다.

| ISSUE_KEY | #transition_name | comment_string |
| --- | --- | --- |
| CDCDEVELOP-234 | #resolve | row chaining 관련 추출 로직 에러. 관련 내용 수정하였습니다. |