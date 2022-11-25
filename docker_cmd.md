# 도커 자주 쓰는 명령어
- `docker ps`: 현재 실행중인 컨테이너 정보 출력
- `docker ps -a`: 모든 컨테이너 정보 출력
- `docker start {container id}`: 컨테이너 시작
- `docker stop {container id}`: 컨테이너 정지

- `docker image`
    - `docker image ls`: 이미지 목록
    - `docker image tag`: 이미지 이름 및 태그 변경
    - `docker image save -o {파일명}.tar {이미지명or id}`: 이미지 저장(output)
    - `docker image load -i {파일명}.tar`: 이미지 로드(input)

- `docker container`
    - `docker container ls`: 활성화된 컨테이너 목록
    - `docker container ls -a`: 비활성화된 컨테이너 포함하여 등록된 모두 출력

- `docker export {컨테이너명or id} > {파일명}.tar`: 컨테이너 저장
- `docker import {파일명or URL}`: export했던 파일로 이미지 생성

- `docker compose`
    - docker설치시 함께 설치한 docker-compose-plugin
    - `docker-compose`
        - `docker-compose` 커맨드를 씀.  이건 구버전이다.
    - `docker compose up`: 설정파일에 기술된 컨테이너들을 실행
    - `docker compose up -d`: 설정파일에 기술된 컨테이너들을 daemon으로 실행
    - 설정파일: `docker-compose.yml`
        - 보통 배포 프로젝트의 최상단 경로에 둔다.
        - 현재경로 or 상위경로를 조회한다.