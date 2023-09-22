# 쿠버네티스에서 로깅

특히 운영 상 필요한 앱 로그 위주의 모니터링 방법들

## 간단한 로그 조회

```sh
# kubectl logs {POD_NAME}
kubectl logs podname-xxxxxxxxxxx-xxxx
```

- **pod 내 stdout, stderr 조회**
- pod에 container가 여러 개면, -c옵션으로 특정 container 지정가능
- 일반적으로 별도 설정없이 Pod 로그 조회만으로 앱 로그 확인가능
  - 요즘 대부분 상용툴은 로거가 포함되어 있고, 파일로 로그를 저장
  - But, 이런 툴들의 이미지 배포판에선 로거에서 파일대신 stdout, stderr로 처리하도록 설정되어 있음

## 장기 로그 조회

### 로컬 호스트(노드)에 저장된 로그 파일 직접 조회

- Pod 종료시 해당 로그파일 삭제됨
- 아래 경로에서 로그파일들은 symbolic link 되어있어서, 서로 같은 내용인데 분류만 다름

```sh
# 1. Container 기준 분류
/var/log/containers/

# 2. Pod 기준 분류
/var/log/pods/

# 3. Docker 사용시
/var/lib/docker/containers
```

### 로그파일 Rotation 정책

- 앱 로그: 10메가 넘으면 rotation
- 시스템 로그: 100메가 넘으면 rotation
- K8s의 로그 저장 정책이 있으나, 사용하는 Container Runtime에 따라 동작이 다를 수 있음

### 컨테이너 런타임으로 Docker 사용시

- K8s 로그(`/var/log/pods/`)는 Docker 로그(`/var/lib/docker/containers`)까지 symbolic link된다.
- Pod 종료로 로그파일 삭제될 시, link된 Docker쪽 로그파일도 삭제됨

### 컨테이너 런타임으로 Docker 사용시 Rotation 정책

- Docker의 default 정책은 없기 때문에, 로그가 무한정 남을 수 있다.
- production 배포시, Docker 로깅드라이버 설정에서 rotation 정책을 설정해주도록 한다.
- `/etc/docker/daemon.json`에서 별도 설정 가능

## 고도화된 로그 조회

K8s 노드(로컬호스트)에 저장되는 로그는 기본적으로 K8s 앱 개발시 최근 로그를 터미널에서 쉽게 조회하는 정도의 목적임

장기보관이나 고도화된 운영로그 조회가 필요하다면 결국은 별도 백엔드 구축 필요

- 앱 로그: Elastic Stack, fluentbit, fluentd 등
- 노드의 시스템로그(metric): Prometheus, Grafana 계열 등

## 참고 자료

[K8s 로깅유형 및 fluentd 예제(공식)](https://kubernetes.io/docs/concepts/cluster-administration/logging/#logging-at-the-node-level)

[K8s 로깅유형, 예제, retention](https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/cluster-administration/logging/)

[K8s 로그 retention 관련 stack overflow](https://stackoverflow.com/questions/71948846/kubernetes-pod-logs-retention)

[Docker에서 로깅 설정(공식)](https://docs.docker.com/config/containers/logging/configure/)

