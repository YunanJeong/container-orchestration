# docker-practice

1. 도커 설치용어 및 라이센스 정리
- Docker Engine
	=> 도커 소프트웨어. "Daemon" 형태로 실행된다.

- Docker CLI
	=> 도커 엔진 사용을 위한 인터페이스 "Client"이다.
	=> 도커 엔진, 도커 CLI, 도커 데스크탑이 그냥 도커라는 단어로 혼용되는데 구분할 필요가 있다.
	=> 도커 엔진과 도커 cli를 같이 설치하다보니 그런 경향이 있다.

- Docker CE
	=> Community Edition
	=> Docker Engine은 CE(Community Edition)와 EE(Enterprise Edition)로 나눠짐
	
- Docker Desktop
	=> 리눅스 기반이 아닌 OS(Windows, Mac)에서 도커를 사용할 수 있게하는 도커엔진을 포함한 툴
	=> 리눅스 버전도 2022년 출시
	=> Docker Engine + Docker CLI + Docker GUI가 포함된 올인원 패키지다.
	=> 2021년 8월부터 대기업 대상으로 유료화 됐다는 건 Docker Desktop을 의미
	
	=> 유료화 대상은 Docker Desktop이지, Docker Engine과 Docker CLI는 무료다.
	=> Docker Engine, CLI를 별도 설치하면 무료로 도커 이용가능하다.
	
	
- 구독 요금
	=> https://www.docker.com/pricing/
	=> Docker Personal, Pro, Team, Bussiness
	=> 그냥 Docker라고 표기하지만 사실상 Docker Desktop에 대한 이야기
	=> 무료인 Personal 구독이 개편 전의 Free 버전을 의미한다.
	
- 회사 업무 목적으로 도커 무료 사용방법
	=> https://www.bearpooh.com/92 (윈도우10에서 Docker Desktop 없이 Docker 사용하기)
	=> WSL에 CLI 기반 도커엔진을 설치한다.
