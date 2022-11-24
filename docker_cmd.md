# 도커 자주 쓰는 명령어
- `docker ps`: 현재 실행중인 컨테이너 정보 출력
- `docker ps -a`: 모든 컨테이너 정보 출력
- `docker start {container id}`: 컨테이너 시작
- `docker stop {container id}`: 컨테이너 정지
- `docker image ls`: 이미지 목록
- `docker image tag`: 이미지 이름 및 태그 변경
- `docker image save -o {파일명}.tar {이미지명or id}`: 이미지 저장(output)
- `docker image load -i {파일명}.tar`: 이미지 로드(input)
- `docker export {컨테이너명or id} > {파일명}.tar`: 컨테이너 저장
- `docker import {파일명or URL}`: export했던 파일로 이미지 생성

- `docker compose`: docker설치시 함께 설치한 docker-compose-plugin 활용
    - (docker-compose 따로 설치하면 `docker-compose` 커맨드를 쓰는데, 이건 구버전이다.)