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
    - 컨테이너 내부 커맨드 실행

- `docker run {image}`
    - image를 container로 띄우기. image 없으면 레지스트리에서 자동 pull

- 잡다한 테스트시 `docker run -it ubuntu` 사용
    - 도커허브에 공식배포된 'ubuntu'이미지를 컨테이너로 띄우면서, 내부 쉘로 접속한다.
    - ubuntu 이미지는 그냥 run하면 Fail된다. 우분투 명령어만 수행하고 종료되는 것을 목적으로 설계되었기 때문이다. (`docker ps -a`로 확인해보면 COMMAND가 'bash'로 설정되어 있다.)
    - 대표적으로 ubuntu 이미지가 있지만 이런 사례들이 많다.
    - 이 때 다음 옵션을 써준다.
        - -i: interactive, 계속 상호작용할 수 있도록 stdin을 받게 열어둔다.
        - -t: tty. terminal cli 형태로 띄운다.
    - 특히, ubuntu 이미지의 경우 간단한 ping, apt, cat, ifconfig 등을 자유롭게 테스트해보기에 좋으므로 익숙해지도록 하자.
    - 이미지가 매우 경량화 되어있어서 컨테이너 접속 후 처음에 설치된게 없다. 이 때, apt update 부터 해주도록 하자.
