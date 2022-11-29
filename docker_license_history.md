# 도커 종류, 라이센스, 용어, 히스토리 정리 (2022.11. 기록)

## 개요
- 공식 홈페이지의 라이센스 설명이 불친절하다.
- 정책이 자주 바뀌어서 정확한 정보를 찾기 힘들다. 용어도 뒤죽박죽 혼용된다.
- 가급적 공식출처 기준으로, 여기에 설치용어 및 라이센스 관련 내용을 정리한다.

## 결론
- 회사에서 무료 사용 => docker-ce 설치
- 회사에서 유료 사용 => Docker Desktop 설치
- 개인목적, Windows, Mac에서 편하게, 무료 사용  => Docker Desktop 설치
- 그런거 모르겠고 빨리 설치해서 무료 사용하고 싶다. => docker-ce 설치

## 읽어보면 좋은 글
- [도커 라이센스에 관해 읽어보면 좋은 글](https://forums.docker.com/t/license-to-use-docker-community-edition/114840/4)
- [docker.io vs. docker-ce(라이센스, docker-ee와의 차이 등 포함)](https://stackoverflow.com/questions/45023363/what-is-docker-io-in-relation-to-docker-ce-and-docker-ee-now-called-mirantis-k)

## 용어
### Docker Engine
- 도커 소프트웨어. "Daemon" 형태로 실행된다.
- `Apache 2.0 License`를 따른다. ([공식 출처](https://docs.docker.com/engine/#licensing))
- 도커 컨테이너들이 Docker Engine 위에서 실행된다.

### Docker CLI
- Docker Engine 사용을 위한 인터페이스 클라이언트
- [Docker CLI repo](https://github.com/docker/cli)에서 `Apache 2.0 License`를 확인
- Docker Engine 설치과정상 거의 항상 같이 설치되기때문에 실사용시 이렇게 구분할 필요도 없다. 헷갈려서 정리함.

### `docker.io`
- Debian/Ubuntu의 공식 repos에 배포된 Docker Engine 릴리스
- 오래된 버전
- Docker Engine 및 필요한 플러그인(Docker-cli, ...)이 포함된다
### `docker-ce` (Community Edition)
- docker.com 에서 직접 배포하는 Docker Engine 릴리스
- `docker-ce는 사람들이 많이 쓰는 관례적인 이름`에 가깝고, `도커 공홈에서는 더 공식적인 표현으로 Docker Engine`이라고 칭해진다.
- 다만, 공식 설치 패키지 이름도 여전히 `docker-ce`로 되어있다.
- 설치과정상 docker-cli, docker-compose-plugin 등 플러그인을 함께 설치하게 된다.

### docker.io vs. docker-ce 무엇이 주로 쓰이는가? => 최신버전 `docker-ce`

### `docker-ee` (Enterprise Edition)
- 과거 Docker Engine은 docker-ce(Community Edition)와 docker-ee(Enterprise Edition)로 나눠졌으나 현재 공식 분류 방법이 아님
- docker-ee는 타사에 매각되었기 때문에, 이제 도커 회사에서 다루지 않음
- **따라서, 현재 `Docker Engine` == `docker-ce`**

### `docker-ce` legacy repository: https://github.com/docker/docker-ce
- 보관 용도일뿐 deprecated라고 나온다.
- 단, `Docker Engine(docker-ce)`이 deprecated된 건 아니고 저장소만 deprecated라는 의미이다.
- 위 저장소에서는 현재 저장소 링크를 알려주고 있다.
### `Docker Engine(docker-ce)` current repository: https://github.com/moby/moby
- 현재 'docker-ee'가 없기 때문에, 이것이 관례적으로는 `docker-ce`라 칭해지는 `Docker Engine`의 공식 소스코드라고 볼 수 있다.
- 여기서 Docker Engine이 `Apache 2.0 License`인 것을 다시 확인할 수 있다.

### `Docker Desktop`
- 도커 유료 버전
- Docker Engine + Docker CLI + Docker GUI가 포함된 올인원 패키지
- 리눅스 기반이 아닌 OS(Windows, Mac)에서 도커를 사용할 수 있게하는 툴
- 리눅스 버전도 2022년 출시
- 무료 사용 가능한 케이스
	- 250명 미만 && 10 millon 달러 매출액 미만 기업은 무료
	- 개인사용, 교육목적, 비상업적 이용 무료
- 유료화
	- 2021년 8월부터 대기업 대상으로 유료화 됐다는 건 Docker Desktop을 의미
	- 유료화 대상은 Docker Desktop이지, Docker Engine과 Docker CLI는 아니다. (Apache 2.0)
	- Linux에서 Docker Engine, CLI를 별도 설치하면 무료로 도커 이용가능하다.
- 구독 요금
	- https://www.docker.com/pricing/
	- Docker Personal, Pro, Team, Bussiness
	- 그냥 Docker라고 표기하지만 사실상 Docker Desktop에 대한 이야기
	- 무료인 Personal 구독이 개편 전의 Free 버전을 의미한다.
