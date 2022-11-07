# docker-practice


---
## 도커 설치 방법
### Docker Engine (docker-ce)
- **사람들이 많이쓰는, 회사에서도 사용가능한 버전**
- **Apache 2.0 License**
	- [언급(공식)](https://docs.docker.com/engine/#licensing)
	- [git(공식)](https://github.com/moby/moby/blob/master/LICENSE)
- [설치방법(공식)](https://docs.docker.com/engine/install/ubuntu/)
	- 레포지토리 등록 후 sudo apt install 하는 방식
	- docker-ce는 현재 공식적인 명칭은 아니지만, Docker Engine을 관례적으로 가리키는 말이다. 위 공식 방법으로 설치해도 패키지명은 docker-ce로 표기된다.

### docker.io
- 오래된 도커 버전
- Debian/Ubuntu의 repository에 제공된 docker 릴리즈 이름
- 설치:
```
$ sudo apt update
$ sudo apt install docker.io`
```
### Docker Desktop
- 도커 유료 버전
- 기존 docker 사용시 필요한 플러그인 + GUI 등 편의환경 제공
- Windows, Mac 등 Linux가 아닌 환경을 위한 docker플랫폼이었으나 현재는 Ubuntu 버전도 유료제공
- 250명 미만 && 10 millon 달러 매출액 미만 기업은 무료
- 개인사용, 교육목적, 비상업적 이용 무료

### [도커 라이센스 및 관련 용어 디테일한 히스토리](https://github.com/YunanJeong/docker-practice/blob/main/docker_license_history.md)
