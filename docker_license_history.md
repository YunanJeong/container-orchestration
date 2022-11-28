# 도커 라이센스 및 설치 용어 히스토리 (2022.08. 기록)

## 개요
- 공식 홈페이지의 라이센스 설명이 불친절하다.
- 정책이 자주 바뀌어서 정확한 정보를 찾기 힘들다. 용어도 뒤죽박죽 혼용된다.
- 가급적 공식출처 기준으로, 여기에 설치용어 및 라이센스 관련 내용을 정리한다.

## 읽어보면 좋은 글
- [도커 라이센스에 관해 읽어보면 좋은 글](https://forums.docker.com/t/license-to-use-docker-community-edition/114840/4)
- [docker.io vs. docker-ce(라이센스, docker-ee와의 차이 등 포함)](https://stackoverflow.com/questions/45023363/what-is-docker-io-in-relation-to-docker-ce-and-docker-ee-now-called-mirantis-k)
- `docker.io`
	- Debian/Ubuntu의 공식 repos에 제공된 docker 릴리스 이름
	- 오래된 버전
- `docker-ce`
	- docker.com 에서 직접 제공하는 인증 릴리스
	- 공식문서의 "Docker Engine"은 이것을 의미
- docker.io vs. docker-ce 무엇이 주로 쓰이는가?
	- `docker-ce`

## 본론
- Docker Engine
	- 도커 소프트웨어. "Daemon" 형태로 실행된다.
	- 도커 엔진은 `Apache 2.0 License`를 따른다. ([공식 출처](https://docs.docker.com/engine/#licensing))

- Docker CLI
	- 도커 엔진 사용을 위한 인터페이스 "Client"이다.
	- 도커 엔진, 도커 CLI, 도커 데스크탑이 그냥 도커라는 단어로 혼용된다.
	- 도커 엔진과 도커 cli는 거의 항상 같이 설치하다보니 그런 경향이 있다.
	- [Docker CLI repo](https://github.com/docker/cli)에서 `Apache 2.0 License`를 확인할 수 있다.

- Docker CE(Community Edition) vs. Docker EE(Enterprise Edition)
	- `Docker Engine`은 CE(Community Edition)와 EE(Enterprise Edition)로 나눠졌으나 현재 공식 분류 방법이 아니다.
	- Docker EE는 타사에 매각되었기 때문에, 이제 도커 회사에서 공식적으로 다루지 않는다.
		- 웹서핑 중 등장하는 docker-ee는 관례적으로 남은 표현일 뿐이다.
	- 도커 공홈에서 `Docker Engine`은 주로 `docker-ce`를 의미한다.
		- `docker-ce`도 공식표기는 아니지만, 사용하는 패키지 이름에 `docker-ce`가 남아있다.

	- Ubuntu에 `Docker Engine (docker-ce)` 설치하기 ([공식](https://docs.docker.com/engine/install/ubuntu/))
	- `docker-ce` 레거시 보관용 repository: https://github.com/docker/docker-ce
		- 위 저장소는 보관 용도일뿐 deprecated이다. 단, `Docker Engine(docker-ce)`가 deprecated된 건 아니고 저장소만 deprecated라는 말이다.
		- 위 저장소에서는 다음 링크를 알려주고 있다.
			- https://github.com/moby/moby
			- 현재 'docker-ee'가 없기 때문에, 이것이 관례적으로 `docker-ce`라 칭해지는 `Docker Engine`의 소스코드라고 볼 수 있다.
			- 그리고 이것은 `Apache 2.0 License`이다.

- Docker Desktop
	- 리눅스 기반이 아닌 OS(Windows, Mac)에서 도커를 사용할 수 있게하는 툴
	- Docker Engine + Docker CLI + Docker GUI가 포함된 올인원 패키지다.
	- 리눅스 버전도 2022년 출시

	- 유료화
		- 2021년 8월부터 대기업 대상으로 유료화 됐다는 건 Docker Desktop을 의미
		- 유료화 대상은 Docker Desktop이지, Docker Engine과 Docker CLI는 아니다. (Apache 2.0)
		- Linux에서 Docker Engine, CLI를 별도 설치하면 무료로 도커 이용가능하다.

## 결론
- 구독 요금
	- https://www.docker.com/pricing/
	- Docker Personal, Pro, Team, Bussiness
	- 그냥 Docker라고 표기하지만 사실상 Docker Desktop에 대한 이야기
	- 무료인 Personal 구독이 개편 전의 Free 버전을 의미한다.

- 회사 업무 목적으로 도커 무료 or 우회 사용방법
	- https://www.bearpooh.com/92 (윈도우10에서 Docker Desktop 없이 Docker 사용하기)
	- WSL에 CLI 기반 도커엔진을 설치한다.
