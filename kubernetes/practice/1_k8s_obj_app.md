# K8s의 Object(Resource)

## Pod

- docker run처럼 컨테이너를 일회성으로 띄운다.

  ```sh
  # 빠른 Pod 실행
  kubectl run echo --image ghcr.io/subicura/echo:v1
  ```

- K8s에서는 Pod을 delete해도, 일반적으로 ReplicaSet에 의해 복구되지만, run기반 Pod는 즉시 delete된다.
- Pod은 보통 단독사용하지 않는다.
  - 그럴거면 그냥 docker run을 쓰지.
  - K8s에서는 일반적으로 Pod를 관리하기 위한 오브젝트를 함께 설정한다.

## ReplicaSet(복제셋)

- **지정된 수**의 **동일한 Pod들**이 **항상 실행**되도록 한다.
- 동일한 Pod이 여러 개 필요할 때는 Pod를 일일이 정의하기보다 ReplicaSet을 쓰는 것이 적합
- 지정된 수
  - yaml로 Pod 개수를 간편히 설정가능
  - 실행 중에도 apply 커맨드로 Pod추가 가능(Scale Out), [ReplicaSet 동작과정](https://velog.io/@jee-9/Kubernetes-Replica-Set%EB%A0%88%ED%94%8C%EB%A6%AC%EC%B9%B4%EC%85%8B%EC%97%90-%EB%8C%80%ED%95%98%EC%97%AC#%EC%B0%B8%EA%B3%A0-%ED%8F%AC%EB%93%9C-%EA%B0%AF%EC%88%98-%EB%B0%94%EA%BE%B8%EB%8A%94-%EB%B0%A9%EB%B2%95)
- 동일한 Pod들 (Replicas of Pod)
  - 동일한 Pod 여러 개를 관리하는 것이라서 ReplicaSet(복제본집합)이라고 부른다. (e.g. Cluster시스템의 Node들)
  - 오로지 Pod 메타데이터의 label만을 기준으로 동일한지 판단한다. Pod 내부의 container 구성은 상관없다.
- 항상 실행
  - ReplicaSet을 등록해놓으면, 오류로 인한 종료or 단순 delete해도 pod이 재실행된다.

## Deployment(배포)

- 지정된 수의 Pod 복제본들이 **원하는 상태**로 실행되도록 한다.
- ReplicaSet의 high-level object이며, 내부적으로 ReplicaSet을 사용
- 설정파일도 ReplicaSet과 유사하나, Deployment가 기능이 더 많음
- K8s 개발/운영자는 보통 Deployment만 사용
- 특히, Pod의 **상태를 변경(배포)할 때 Deployment가 유리**
- 업데이트 전략(Strategy)을 설정 가능
  - Rolling updates (default)
    - 업데이트시, 새 ReplicaSet(v2)을 만들고 기존 ReplicaSet(v1)에서 Pod을 하나씩 점진적으로 이전한다.
    - zero-downtime update 보장
  - Recreate
    - 업데이트 대상인 기존 Pod(v1)을 모두 제거한 후 새 Pod(v2) 생성
    - downtime 발생
  - Canary
    - 업데이트 대상인 기존 ReplicaSet(v1)과 새로운 ReplicaSet(v2)가 공존한다.
    - v1 트래픽을 점진적으로 v2로 라우팅시킨다.
    - 에러 발생시 다시 롤백
    - 100%의 트래픽을 v2로 처리했을 때 문제가 없다면 정상 배포 완료된 것으로 볼 수 있다.
- Rollbacks
  - 업데이트 내역이 자동으로 남아서, 이전버전or 특정버전으로 롤백이 쉽다. (버전관리)
  
  ```sh
  # 히스토리 확인
  kubectl rollout history deploy/{deployment-name}

  # revision 1 히스토리 상세 확인
  kubectl rollout history deploy/{deployment-name} --revision=1

  # 바로 전으로 롤백
  kubectl rollout undo deploy/{deployment-name}

  # 특정 버전으로 롤백
  kubectl rollout undo deploy/{deployment-name} --to-revision=2
  ```

- 이 외에도 스케일링 정책, 헬스체크 등 추가기능이 있어 ReplicaSet만 사용하는 것보다 **배포(Deploy)에 유리**하다.

## ReplicaSet vs. Deployment

- 실사용시 핵심차이: **기존 실행중인 Pod의 업데이트 여부**
- ReplicaSet은 Pod 개수만 신경쓴다.
  - ReplicaSet을 apply할 때, Selector와 매칭되는 Pod이 이미 실행중인 경우 해당 Pod은 업데이트되지 않음
  - ReplicaSet의 template에 기술된 정보(image 등)는 Pod 개수가 모자라서 새로 생성되는 Pod에만 적용됨
  - e.g. config파일에서 template의 Pod 정보(container image 등)를 변경 후 apply하면, 해당 config 파일로 기존 실행중인 Pod들은 변경되지 않는다. 바꾸고 싶으면 기존 Pod들을 delete 후 새로 실행해야 한다.
- Deployment는 ReplicaSet기능 + 이미지 변경 등 업데이트 적용
  - e.g. Pod 정보 변경 후 새로 apply하면, 기존 실행중인 Pod에 변경사항이 적용된다.

## Deployment처럼 앱 배포에 쓰일 수 있는 Pod의 상위 레이어 리소스 유형

- StatefulSet
  - 상태 유지가 필요한 애플리케이션을 관리
  - 예를 들어 데이터베이스, 분산 메시지 큐 등
- DaemonSet
  - 클러스터의 모든 노드 또는 특정 노드에서 Pod를 실행
  - 로그 수집기, 노드 모니터링 등에 사용됨
- Job
  - 한번만 실행되거나 완료될 때까지 실행되는 작업을 관리백업 작업
  - 일괄처리 작업 등
- CronJob
  - 주기적으로 실행되는 작업을 관리합니다. 정기 백업, 매일 실행되는 배치 작업 등

## namespace

- 한 클러스터 내에서 Resource들을 묶고 환경을 격리하는 방법
- 네임스페이스가 다르면 Object 이름이 중복돼도 괜찮다.
- 용도1: 사용자환경 분리
  - 여러 사용자나 팀이 한 클러스터에서 작업할 때 환경 분리
  - 차등적인 권한부여 가능
- 용도2: 개발환경 분리
  - dev/test/production 등으로 나누어서 작업 가능
- 용도3: 리소스 제어
  - namespace로 묶은 리소스들에 대해서 CPU/GPU 허용량을 할당 가능

```sh
# namespace 목록 조회
kubectl get ns

# namespace에 속한 Object 조회
kubectl get all -n {namespace_name}
```

## DaemonSet

- 클러스터 내 모든 (또는 일부) 노드에서 파드의 사본을 실행하도록 하는 리소스
- 특정 노드에 시스템 데몬 배포시 유용(e.g. 로그 수집기, 모니터링 에이전트)
- 신규 Node가 클러스터에 추가될 시 DaemonSet으로 설정된 앱은 신규 Pod로 해당 Node에 추가 실행됨, Node 제거시에도 마찬가지로 자동삭제

### hostPort로 네트워크 노출

- DaemonSet으로 배포되는 Pod는, `hostPort`방식의 네트워크 노출이 종종 사용됨
- Host(Node)의 특정 Port에 Container의 Port를 바인딩하는 방식
  - `도커 네트워크 호스트 모드 or Native 앱 설치와 비슷한 효과`
- K8s에서 일반적인 네트워크 노출방식은 후술할 Service 또는 Ingress 방식이 적절하지만, 로그수집기처럼 DaemonSet으로 Node마다 배포되어야 하는 앱들은 hostPort 방식이 편리

## StatefulSet

- `상태 유지가 필요한 Stateful App. 을 배포할 때 유용`한 오브젝트
- 이를테면 껐다켜도 정보를 보존해야하는 `메시지큐, DB` 등이 Stateful App.에 해당
- 특히 `동일한 종류의 여러 Pod(Replica)를 관리하는데 최적화`되어 있으며, `Kafka, Elasticsearch와 같은 클러스터 시스템 배포에 특화`
- Deployment처럼 Pod 배포를 위한 상위 계층 오브젝트이지만, ReplicaSet을 하위 오브젝트로 가지진 않는다.

### StatefulSet vs. Deployment

- Deployment와 역할, 매니페스트 구성이 거의 유사하나 일부 차이점이 있는데 이것이 StatefulSet의 특징이라 볼 수 있음
- 고유한 네트워크 ID
  - 매니페스트에서 `serviceName` 필드 지정
- Pod 생성,삭제,업데이트시 순차적 동작 보장
  - Deployment배포에선, Pod는 동시 생성, 동시 삭제된다. 업데이트시엔 개별 정책 설정대로 동작한다.
  - StatefulSet은 "0번, 1번, 2번, ..." Pod 순대로 실행되고 "..., 2번, 1번, 0번" Pod 순으로 삭제된다.
- 안정적인 스토리지
  - PVC 자동 생성 기능 (`volumeClaimTemplates` 필드)
  - StatefulSet은 `Pod가 재실행되어도 처음 바인딩된 특정 번호의 Pod, 특정 번호의 PV, 자동생성된 PVC가 고정적으로 서로 바인딩되어 지속성`을 가지도록 해줌
  - 참고: 동적&정적 프로비저닝과는 다른 개념이다. 프로비저닝 방식은 PV를 어떻게 생성하냐에 대한 것이고, 여기서는 PVC를 자동생성하느냐에 대한 것임

## 네트워크 설정에 필요한 K8s Object

분량이 많으므로 별도 파일에 정리

### Service

### Ingress
