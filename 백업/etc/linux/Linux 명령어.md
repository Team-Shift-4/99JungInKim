# 리눅스 명령어

# 주요 명령어

- `ls`
    
    List Segments: 현재 위치의 파일 목록 조회
    
    | -l | 파일의 상세정보 |
    | --- | --- |
    | -a | 숨김 파일 표시 |
    | -t | 파일들을 생성시간 역순으로 표시 |
    | -rt | 파일들을 생성시간순으로 표시 |
    | -f | 파일 표시 시 마지막 유형에 나타내는 파일명을 끝에 표시
    /: 디렉터리, *: 실행파일, @: 링크 등 |
- `cd`
    
    Change Directory: 디렉터리 이동
    
    | [route] | 기입한 루트의 디렉터리로 이동 |
    | --- | --- |
    | ~ | 홈 디렉터리로 이동 |
    | / | 최상위 디렉터리로 이동 |
    | . | 현재 디렉터리 |
    | .. | 상위 디렉터리로 이동 |
    | - | 이전 경로로 이동 |
- `touch`
    
    0 byte 파일 생성, 파일의 날짜, 시간을 수정
    
    | [file] | file을 생성 |
    | --- | --- |
    | -c [file] | file의 시간을 현재시간으로 갱신 |
    | -t [YYYYMMDDhhmm] [file] | file의 시간을 YYYYMMDDhhmm으로 갱신 |
    | -r [oldfile] [newfile] | newfile의 날짜 정보를 oldfile과 동일하게 변경 |
- `mkdir`
    
    MaKe DIRtory: 디렉터리 생성
    
    | [dir] | dir인 디렉터리 생성 |
    | --- | --- |
    | [dir1] [dir2] | dir1, dir2 디렉터리 생성 |
    | -p [dir1]/[dir2] | dir1 디렉터리 생성, dir2 하위 디렉터리 생성 |
    | -m [Permission] [dir] | Permission을 갖는 dir인 디렉터리 생성 |
    - Permission
        
        2진수 기준 자리 수가 1일 때 권한이 있음
        
        1의 자리 → 실행
        
        2의 자리 → 쓰기
        
        4의 자리 → 읽기
        
        Permission은 8진수 기준 3자리
        
        1의 자리 → 일반 사용자
        
        8의 자리 → 소유 그룹
        
        64의 자리 → 소유자
        
- `cp`
    
    CoPy: 파일 복사
    
    | [file1] [file2] | file1을 file2라는 이름으로 복사 |
    | --- | --- |
    | -f [file1] [file2] | 강제 복사(file2가 존재 시 대치) |
    | -r [dir1] [dir2] | 디렉터리 복사
    폴더 안 모든 하위 경로, 파일 복사 |
- `mv`
    
    MoVe: 파일 이동
    
    | [file1] [file2] | file1을 file2로 변경 |
    | --- | --- |
    | [file1] /[dir] | file1을 dir로 이동 |
    | [file1] [file2] /[dir] | file1, file2를 dir로 이동 |
    | /[dir1] /[dir2] | dir1을 dir2로 이름 변경 |
- `rm`
    
    ReMove: 파일 삭제
    
    | [file] | file을 삭제 |
    | --- | --- |
    | -f [file] | file을 강제삭제 |
    | -r dir | dir를 삭제
    (디렉터리는 -r 옵션 없이 삭제 불가) |
- `cat`
    
    CATenate: 파일의 내용을 화면에 출력
    redirection 기호를 사용하여 새 파일 생성
    
    | [file] | file의 내용 출력 |
    | --- | --- |
    | [file1] [file2] | file1과 file2의 내용 출력 |
    | [file1] [file2] | more | file1과 file2의 내용을 페이지 별로 출력 |
    | [file1] [file2] | head | file1과 file2의 내용을 상위 10줄만 출력 |
    | [file1] [file2] | tail | file1과 file2의 내용을 하위 10줄만 출력 |
    - redirection
        - `>`: 기존에 있는 파일 내용을 지우고 저장
        - `>>`: 기존 파일 내용 뒤에 덧붙여서 저장
        - `<`: 파일의 데이터를 명령에 입력
        
        ex)
        
        | cat [file1] [file2] > [file3] | file1, file2의 명령 결과를 합쳐 file3에 저장 |
        | --- | --- |
        | cat [file1] >> [file2] | file2에 file1의 내용 추가 |
        | cat < [file] | file의 결과 출력 |
        | cat < [file1] > [file2] | file1의 출력 결과를 file2에 저장 |
- `alias`
    
    별칭 지정
    
    ```bash
    alias [nick] = '[command]'
    #nick을 실행하면 command가 실행
    unalias [nick]
    #nick이라는 alias 해제
    ```
    
    ```bash
    #ex)
    alias lsa = 'ls -a'
    unalias lsa
    ```
    
- `tail`
    
    파일의 뒷부분을 보여줌
    
    옵션 없이 사용 시 마지막 10줄 보여줌
    
    | [file] | file의 마지막 10줄을 보여줌 |
    | --- | --- |
    | -f [file] | tail을 종료하지 않고 file의 업데이트 내용을 실시간 출력 |
    | -n (라인 수) [file] | file의 마지막 줄부터 지정한 라인 수 까지 출력 |
    | -c (바이트 수) [file] | file의 마지막부터 지정한 바이트만큼 출력 |
    | -q [file] | file의 헤더와 상단의 파일 이름을 출력하지 않고 내용만 출력 |
    | -v [file] | file의 헤더와 이름먼저 출력한 후 내용 출력 |
- `grep`
    
    특정 패턴 찾는 명령어
    
    | -A [N] | 특정 문자열부터 N 이후 라인까지 출력 |
    | --- | --- |
    | -B [N] | 특정 문자열부터 N 이전 라인까지 출력 |
    | -C [N] | -A [N] -B [N] |
    | --color=[when] | 특정 문자열을 특정 색으로 표시
    [when]: never, always, auto |
    | -d [action] | 특정 디렉터리에서 특정 문자열 검색 |
    | -e [pattern] | 여러 특정 문자열로 검색 |
    | -i | 특정 문자열을 대소문자 구별 없이 검색 |
    | -v | 특정 문자열을 제외한 나머지 행 검색 |
    | -w | 다른 문자열이 포함되지 않은 문자열만 검색 |