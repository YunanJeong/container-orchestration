# Docker



# 도커 설치 방법 (Ubuntu)

## 도커 설치 유형 및 라이센스 정리
[설치유형 및 라이센스](https://github.com/YunanJeong/docker-practice/blob/main/docker_license_history.md)


## 공식 & 최신 Docker Engine (docker-ce)
- **Apache 2.0 License**
	- 공식 출처: [[1]](https://docs.docker.com/engine/#licensing)[[2]](https://github.com/moby/moby/blob/master/LICENSE)
	- 사람들이 많이쓰는, 회사에서도 사용가능한 버전
- [ubuntu에서 설치방법(공식)](https://docs.docker.com/engine/install/ubuntu/)
	- 레포지토리 등록 후 apt install
	- 또는, deb패키지파일을 다운받아서 설치


- docker-ce는 현재 공식명칭은 아니지만, 여전히 Docker Engine을 관례적으로 가리키는 말이다.
	- 위 공식 방법으로 설치해도 패키지명은 docker-ce로 표기된다.
- [WSL에서 설치시 참고(init vs. systemd)](https://github.com/YunanJeong/linux-tips/blob/main/wsl-service-init-vs.systemd/README.md)
	- Docker Engine은 백그라운드로 항상 실행되는 프로세스로, 현재 작동 유무 체크를 위해 서비스 관리자가 필요
- [도커를 non-root 권한으로 사용하기](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)
	- 종종 필요하다.

