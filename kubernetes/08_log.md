# 쿠버네티스에서 로깅

특히 운영 상 필요한 앱 로그 위주의 모니터링 방법들

## 간단한 로그 조회 (Pod 로그)

```sh
# Pod 로그 조회 
# kubectl logs {POD_NAME}
kubectl logs 
```

```sh
# pod에 container가 여러 개면, -c옵션으로 특정 container 지정가능
# kubectl logs {POD_NAME} -c {CONTAINER_NAME}
kubectl logs my-pod-xxxxx -c my-container

# container 목록 조회 방법
kubectl describe pod my-pod-xxxxx
```

### `Pod로그 = Container로그 = App.표준출력(stdout/stderr)`을 의미

- K8s에선 별도 설정이 없더라도 컨테이너 내부의 stdout/stderr이 Pod 로그로 연계됨
- 직접 개발 앱: `K8s에 배포할 앱은 로그출력을 stdout/stderr로 설정하는 것이 정석`
- 범용 이미지 (DB, Elasticsearch, Kafka, ... )
  - 네이티브 앱에선 기본 로그출력이 file인 경우가 많으나,
  - 이들의 이미지 배포판에선 대부분 기본 로그출력이 stdout/stderr으로 설정되어 있음
  - 따라서, 범용 이미지에선 사용자가 로그출력을 고려하지 않아도 Pod,Container로그 조회시 대상 앱의 로그를 확인가능

## 로그 저장 정책

### 로컬 호스트(노드)에 저장된 로그 파일 직접 조회

- 각 Pod 로그는 로컬 호스트(노드) 특정 경로에 취합되어 자동 저장됨
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

### K8s의 로그 저장 Rotation 정책

- 앱 로그: 10메가 넘으면 rotation
- 시스템 로그: 100메가 넘으면 rotation
- 위와 같은 디폴트 설정이 있으나 구체적인 수치는 K8s 배포판마다 다름
- 대부분 K8s 배포판에서 kubelet 관련 config에서 정책 변경 가능
- 사용하는 Container Runtime에 따라 동작이 다를 수 있음

### 컨테이너 런타임으로 Docker 사용시

- 일반적으로 Docker의 로그정책이 더 우선시됨
- K8s 로그(`/var/log/pods/`)는 Docker 로그(`/var/lib/docker/containers`)로 symbolic link된다.
- Pod 종료로 로그파일 삭제될 시, link된 Docker쪽 로그파일도 삭제됨

### 컨테이너 런타임으로 Docker 사용시 Rotation 정책

- `Docker의 default 정책은 없기 때문에, 미설정시 로그가 무한정 남을 수 있다.`
- production 배포시, Docker 로깅드라이버 설정에서 rotation 정책을 설정해주도록 한다.
- `/etc/docker/daemon.json`에서 설정 가능
  - max-size: 한 파일의 최대 크기
  - max-file: 총 허용 파일 개수. 초과시 오래된 것 삭제.
  - 시간 기반 설정은 없음
  - 파일 수정 후 Docker 서비스 재시작하면 반영됨

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

## 고도화된 로그 조회

- K8s 노드(로컬호스트)에 저장되는 로그는 최근 로그를 터미널에서 간단히 조회하는 정도로 사용됨. Pod 별, Node 별로 흩어져 있어서 취합하여 조회&관리가 힘듦.
- 장기보관용/중앙화된/고도화된 운영로그 조회가 필요하다면 결국은 별도 백엔드 구축 필요

### 앱 로그

- ELK, EFK, PLG Stack (Elasticsearch, fluentd, Loki, ...)

### 노드의 시스템로그(metric)

- Exporter-Prometheus-Grafana: Pull방식
- telgraf-influxDB: Push방식

## 참고 자료

[K8s 로깅유형 및 fluentd 예제(공식)](https://kubernetes.io/docs/concepts/cluster-administration/logging/#logging-at-the-node-level)

[K8s 로깅유형, 예제, retention](https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/cluster-administration/logging/)

[K8s 로그 retention 관련 stack overflow](https://stackoverflow.com/questions/71948846/kubernetes-pod-logs-retention)

[Docker에서 로깅 설정(공식)](https://docs.docker.com/config/containers/logging/configure/)
