# 도커 자주 쓰는 명령어
- `docker ps`: 현재 실행중인 컨테이너 정보 출력
- `docker ps -a`: 모든 컨테이너 정보 출력
- `docker start {container id or NAME}`: 컨테이너 시작
- `docker stop {container id or NAME}`: 컨테이너 정지
- `docker export {컨테이너명or id} > {파일명}.tar`: 컨테이너 저장
- `docker import {파일명or URL}`: export했던 파일로 이미지 생성
- `docker container`
    - `docker container ls`: `docker ps`와 동일
    - `docker container ls -a`: `docker ps -a`와 동일

- `docker image`
    - `docker image ls`: 이미지 목록
    - `docker image tag`: 이미지 이름 및 태그 변경
    - `docker image save -o {파일명}.tar {이미지명or id}`: 이미지 저장(output)
    - `docker image load -i {파일명}.tar`: 이미지 로드(input)

- `docker compose`
    - docker설치시 함께 설치한 docker-compose-plugin
        - docker와 별도 설치하는 `docker-compose`는 구버전이다.
        - 현재 도커컴포즈는 docker 프로젝트에 통합되었다.
    - `docker compose up`: 설정파일에 기술된 컨테이너들을 실행
    - `docker compose up -d`: 설정파일에 기술된 컨테이너들을 daemon으로 실행
    - `docker compose down`: up한것들 다시 내리기.
        - down으로 전체 종료시, 개별 컨테이너들은 비활성화되는 것이 아니라 삭제된다.
    - 설정파일: `docker-compose.yml`
        - 보통 배포 프로젝트의 최상단 경로에 둔다.
        - 현재경로 or 상위경로를 조회한다.

- `docker exec {container id} {command}`
    - 컨테이너 내부에서 커맨드 실행