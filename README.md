# docker-practice

## 도커 설치용어 및 라이센스 정리 (2022.08. 기록)

- 라이센스에 관한 읽어보면 좋은 글
	- https://forums.docker.com/t/license-to-use-docker-community-edition/114840/4

- Docker Engine
	- 도커 소프트웨어. "Daemon" 형태로 실행된다.
	- 도커 엔진은 Apache 2.0 License를 따른다. 공식 출처: https://docs.docker.com/engine/#licensing

- Docker CLI
	- 도커 엔진 사용을 위한 인터페이스 "Client"이다.
	- 도커 엔진, 도커 CLI, 도커 데스크탑이 그냥 도커라는 단어로 혼용되는데 구분할 필요가 있다.
	- 도커 엔진과 도커 cli를 같이 설치하다보니 그런 경향이 있다.
	- Docker CLI repo에서 Apache 2.0 License를 확인할 수 있다. https://github.com/docker/cli

- Docker CE(Community Edition) vs. Docker EE(Enterprise Edition)
	- "도커 엔진"은 CE(Community Edition)와 EE(Enterprise Edition)로 나눠졌으나 현재는 공식적인 분류 방법이 아니다. 
	- Docker CE 보관용 repository: https://github.com/docker/docker-ce	
		- 위 저장소도 보관 용도일뿐 deprecated이다. 단, Docker CE가 deprecated된 건 아니고 저장소만 deprecated라는 말이다.
		- 
	
- Docker Desktop
	- 리눅스 기반이 아닌 OS(Windows, Mac)에서 도커를 사용할 수 있게하는 툴
	- Docker Engine + Docker CLI + Docker GUI가 포함된 올인원 패키지다.
	- 리눅스 버전도 2022년 출시
	
	- 유료화
		- 2021년 8월부터 대기업 대상으로 유료화 됐다는 건 Docker Desktop을 의미
		- 유료화 대상은 Docker Desktop이지, Docker Engine과 Docker CLI는 아니다. (Apache 2.0)
		- Linux에서 Docker Engine, CLI를 별도 설치하면 무료로 도커 이용가능하다.
	
- 구독 요금
	- https://www.docker.com/pricing/
	- Docker Personal, Pro, Team, Bussiness
	- 그냥 Docker라고 표기하지만 사실상 Docker Desktop에 대한 이야기
	- 무료인 Personal 구독이 개편 전의 Free 버전을 의미한다.
	
- 회사 업무 목적으로 도커 무료 or 우회 사용방법
	- https://www.bearpooh.com/92 (윈도우10에서 Docker Desktop 없이 Docker 사용하기)
	- WSL에 CLI 기반 도커엔진을 설치한다.

- docker.io vs. docker-ce
	- https://stackoverflow.com/questions/45023363/what-is-docker-io-in-relation-to-docker-ce-and-docker-ee-now-called-mirantis-k
