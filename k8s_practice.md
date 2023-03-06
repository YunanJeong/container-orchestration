# minikube
## requirement
- 2코어, 2GB 메모리 필요
- [도커를 non-root 권한으로 사용하기](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

## Installation
[minikube 시작하기(공식)](https://minikube.sigs.k8s.io/docs/start/)
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```
## 참고 Guide
[쿠버네티스 안내서(기초 학습 및 실습용으로 훌륭)](https://subicura.com/k8s)

## Command
- `minikube kubectl -- `
    -  minikube의 서브커맨드로 일반적인 kubectl의 명령어를 실행 가능
    - `alias kubectl="minikube kubectl --"`를 `~/.bashrc`에 등록하여 편하게 쓰자
- `minikube ip`
    - 현재 작업중인 host 내에서 minikube가 점유한 private ip
- `minikube service {service_name}`
    - k8s에서 service마다 ip가 할당되는데, minikube 등을 사용 중이라면 **minikube 내부에서 private ip**가 할당된 것이므로, localhost에서 바로 접근이 안될 수 있다.
    - 이 때 이 명령어를 이용하면 한단계 더 포트포워딩하여 localhost에서 접속가능한 포트가 제공된다.
- `minikube dashboard`
    - k8s 대시보드 실행. 접속은 브라우저에서
    - 대시보드 자체는 minikube 전용이 아니라, 일반적인 k8s의 모니터링 대시보드
---
# kubectl
- [kubectl 명령어 참고자료](https://subicura.com/k8s/guide/kubectl.html#kubectl-%E1%84%86%E1%85%A7%E1%86%BC%E1%84%85%E1%85%A7%E1%86%BC%E1%84%8B%E1%85%A5)
- kubectl
    - apply
    - delete
    - get
    - describe
    - logs
    - exec
    - config 

1. kubectl apply -f {k8s설정파일명.yml or URL}
2. kubectl delete -f {k8s설정파일명.yml or URL}
3. kubectl get
    ```
    # 모든 Object 조회 (pod, service, deployment, job, replicaset)
    kubectl get all

    # Type 별 Object 조회, 복수단수, 줄임말 혼용가능
    kubectl get pods (pod, po)
    kubectl get pods -A
    kubectl get services (service, svc)
    kubectl get deployments (deployment, deploy)
    kubectl get jobs (job)
    kubectl get replicasets (replicaset, rs)

    # 여러 개 골라서 조회
    kubectl get po,rs
    ```
4. kubectl describe {TYPE}/{NAME} or {TYPE} {NAME}
    ```
    # TYPE은 pod, service 등 Object Type을 의미
    # Object 먼저 조회하여 Name을 확인하고 다음과 같이 사용
    kubectl describe pods/podname-xxxxxxxxxxx-xxxx`
    kubectl describe pods podname-xxxxxxxxxxx-xxxx`
    ```
5. kubectl logs {POD_NAME}
    - pod의 로그 조회
    - pod에 container가 여러 개면, -c옵션으로 특정 container 지정
    - **여기서 보여주는 로그는 pod내에서 발생하는 stdout, stderr**다.
    ```
    kubectl logs podname-xxxxxxxxxxx-xxxx
    ```
6. kubectl exec {POD_NAME} -- {COMMAND}
    ```
    # 1회성 커맨드
    kubectl exec podname-xxxxxxxxxxx-xxxx -- ls

    # 원격접속(-it 옵션, bash 커맨드 사용)
    kubectl exec -it podname-xxxxxxxxxxx-xxxx -- bash
    ```
7. kubectl config {subcommand}
    - k8s에서 context: 여러 개의 k8s cluster들을 다룰 때, kubectl이 어느 cluster에 연결되었는지, 어떻게 인증할지에 대한 정보
    ```
    # 현재 컨텍스트 조회
    kubectl config current-context
    ```
---
# Pod
- 빠른 Pod 실행
```
kubectl run echo --image ghcr.io/subicura/echo:v1
```
- docker run처럼 컨테이너를 일회성으로 띄운다.
- K8s에서는 Pod을 delete해도, 일반적으로 ReplicaSet에 의해 복구되지만, run기반 Pod는 즉시 delete된다.
- Pod은 보통 단독사용하지 않는다.
    - 그럴거면 그냥 docker run을 쓰지.
    - K8s에서는 일반적으로 Pod를 관리하기 위한 오브젝트를 함께 설정한다.

# ReplicaSet(복제셋)
- **지정된 수**의 **동일한 Pod들**이 **항상 실행**되도록 한다.
- 동일한 Pod이 여러 개 필요할 때는 Pod를 일일이 정의하기보다 ReplicaSet을 쓰는 것이 적합
- 지정된 수
    - yaml로 Pod 개수를 간편히 설정가능
    - 실행 중에도 apply 커맨드로 새로운 설정 반영가능(Scale Out), [ReplicaSet 동작과정](https://velog.io/@jee-9/Kubernetes-Replica-Set%EB%A0%88%ED%94%8C%EB%A6%AC%EC%B9%B4%EC%85%8B%EC%97%90-%EB%8C%80%ED%95%98%EC%97%AC#%EC%B0%B8%EA%B3%A0-%ED%8F%AC%EB%93%9C-%EA%B0%AF%EC%88%98-%EB%B0%94%EA%BE%B8%EB%8A%94-%EB%B0%A9%EB%B2%95)
- 동일한 Pod들 (Replicas of Pod)
    - 동일한 Pod 여러 개를 관리하는 것이라서 ReplicaSet(복제본집합)이라고 부른다. (e.g. Cluster시스템의 Node들)
    - 오로지 Pod 메타데이터의 label만을 기준으로 동일한지 판단한다. Pod 내부의 container 구성은 상관없다.
- 항상 실행
    - ReplicaSet을 등록해놓으면, 오류로 인한 종료or 단순 delete해도 pod이 재실행된다.

# Deployment
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
    ```
    # 히스토리 확인
    kubectl rollout history deploy/echo-deploy

    # revision 1 히스토리 상세 확인
    kubectl rollout history deploy/echo-deploy --revision=1

    # 바로 전으로 롤백
    kubectl rollout undo deploy/echo-deploy

    # 특정 버전으로 롤백
    kubectl rollout undo deploy/echo-deploy --to-revision=2
    ```
- 이 외에도 스케일링 정책, 헬스체크 등 추가기능이 있어 ReplicaSet만 사용하는 것보다 **배포(Deploy)에 유리**하다.

# ReplicaSet vs. Deployment
- 실사용시 핵심차이: **기존 실행중인 Pod의 업데이트 여부**
- ReplicaSet은 Pod 개수만 신경쓴다. 
    - ReplicaSet을 apply할 때, Selector와 매칭되는 Pod이 이미 실행중인 경우 해당 Pod은 업데이트되지 않음
    - ReplicaSet의 template에 기술된 정보(image 등)는 Pod 개수가 모자라서 새로 생성되는 Pod에만 적용됨
    - e.g.) config파일에서 template의 Pod 정보(container image 등)를 변경 후 apply하면, 해당 config 파일로 기존 실행중인 Pod들은 변경되지 않는다. 바꾸고 싶으면 기존 Pod들을 delete 후 새로 실행해야 한다.
- Deployment는 ReplicaSet기능 + 이미지 변경 등 업데이트 적용
    - e.g.) Pod 정보 변경 후 새로 apply하면, 기존 실행중인 Pod에 변경사항이 적용된다.

# Service
- This component acts as an abstract layer that exposes a set of Pods to the network as a single endpoint.
- Services provide load balancing, service discovery, and other features to the Pods.
- They allow network communication between the Pods and other components in the cluster, and abstract the underlying network topology.
- Pod에도 private IP가 할당되지만, 자주 꺼졌다 켜질 수 있기 때문에 직접통신은 비권장 사항이다.
- Pod 내부의 container들 끼리는 localhost를 공유하지만, Pod끼리는 IP로 통신해야 한다.
- Service는 **클러스터 외부 네트워크 노출**or **클러스터 내부 오브젝트간 통신**을 책임진다.

## Service Type
- `ClusterIP` is the default Service type and provides a virtual IP address inside the cluster to access the Pods.
- `NodePort` opens a static port on each node's IP address, routing traffic to the Service to the corresponding Pod. (ClusterIP 기능 포함)
- `LoadBalancer` allocates an external IP address to the Service to route traffic to the Pod, typically by using a cloud provider's load balancer.(NodePort 기능 포함)
- `ExternalName` is used to provide DNS aliases to external services.