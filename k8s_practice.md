# minikube
## Installation
- 참고: [minikube 시작하기(공식)](https://minikube.sigs.k8s.io/docs/start/)
- 2코어, 2GB 메모리 필요
- Container Runtime 필요
    - 도커 사용시 [도커를 non-root 권한으로 사용](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) 필요
    ```
    # 다운로드 및 설치
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    sudo dpkg -i minikube_latest_amd64.deb
    ```
## Command
- `minikube start`
    - 시작하기. **minikube는 Container로 실행**된다.
- `minikube kubectl -- `
    -  minikube의 서브커맨드로 일반적인 kubectl의 명령어를 실행 가능
    - `alias kubectl="minikube kubectl --"`를 `~/.bashrc`에 등록하여 편하게 쓰자
- `minikube ip`
    - 현재 작업중인 host 내에서 minikube가 점유한 private ip
    - K8s 클러스터의 노드 ip를 의미
- `minikube service {service_name}`
    - K8s에서 service마다 ip가 할당되는데, 이는 K8s 클러스터 환경 내 private ip이다. 따라서 localhost에서 직접 접근이 불가하다.
    - 이 때 이 명령어를 이용하면 한단계 더 포트포워딩하여 localhost에서 접속가능한 포트가 제공된다.
- `minikube dashboard`
    - k8s 대시보드 실행. 접속은 브라우저에서
    - 대시보드 자체는 minikube 전용이 아니라, 일반적인 k8s의 모니터링 대시보드
---
# K3s
## Intallation
- [요구사항(포트, 메모리 등)](https://docs.k3s.io/installation/requirements)
- [K3s 시작, 설치](https://docs.k3s.io/quick-start)
```
# K3s 설치
curl -sfL https://get.k3s.io | sh -

# 새 노드 추가시 설치(환경 변수 설정 및 클러스터 참여)
curl -sfL https://get.k3s.io | K3S_URL=https://{myserver}:6443 K3S_TOKEN={mynodetoken} sh -
```
## 참고
- K3s 프로세스는 daemon으로 실행된다.
- 클러스터 내 container는 containerd로 실행된다. (별도 설치 필요없음.default)

## Command
```
# k3s 서브커맨드로 kubectl
sudo k3s kubectl

# 직접 kubectl도 사용가능
# (kubectl->k3s로 bin파일 link됨, k3s 설치시 default)
sudo kubectl

# sudo 없이 쓰기 (sudo 필수 서브커맨드들은 여전히 있음)
sudo chmod -R 777 /etc/rancher/k3s/k3s.yaml
```

```
# k3s는 daemon으로 실행된다.
sudo k3s server

# node
sudo k3s agent
```
---
# 참고 Guide
[쿠버네티스 안내서(기초 학습 및 실습용으로 훌륭)](https://subicura.com/k8s)

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
# K8s의 Object(Resource)
## Pod
- docker run처럼 컨테이너를 일회성으로 띄운다.
    ```
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
    ```
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
    - e.g.) config파일에서 template의 Pod 정보(container image 등)를 변경 후 apply하면, 해당 config 파일로 기존 실행중인 Pod들은 변경되지 않는다. 바꾸고 싶으면 기존 Pod들을 delete 후 새로 실행해야 한다.
- Deployment는 ReplicaSet기능 + 이미지 변경 등 업데이트 적용
    - e.g.) Pod 정보 변경 후 새로 apply하면, 기존 실행중인 Pod에 변경사항이 적용된다.

## Service
- This component acts as an abstract layer that exposes a set of Pods to the network as a single endpoint.
- Services provide load balancing, service discovery, and other features to the Pods.
- They allow network communication between the Pods and other components in the cluster, and abstract the underlying network topology.

### Pod에 priviate IP가 할당되는데, 굳이 또 다른 private IP인 Service IP를 거쳐서 통신하는 이유
- Pod은 자주 재실행되면서 IP가 변경될 수 있기에 직접통신은 비권장 사항
- 여러 Pod들을 묶어서 함께 관리하기 용이함
    - 여러 Pod에 트래픽을 분산시키는 로드밸런싱 기능 구현 가능
    - Pod 내부의 container들 끼리는 localhost를 공유하지만, Pod끼리는 IP로 통신 필요
    - 클러스터 내부 Pod끼리 통신시 Service의 IP 대신 name을 DNS alias 처럼 사용 가능
        - => Pod의 IP,name은 다양하고 변화해서 관리하기 번거롭다.
        - => 대신, Service name과 개별 port는 고정해놓고 관리하기 쉽다.
- Service는 **클러스터 외부 네트워크 노출**or **클러스터 내부 오브젝트간 통신**을 책임진다.

### Service Type
1. `ClusterIP` is the default Service type and provides **a virtual IP address** inside the cluster to access the Pods.
    - 주 사용목적: 동일 클러스터내 Pod들 간 통신을 관리
    - 어떤 타입의 Service든 기본할당되는 IP를 의미
    - Service IP는 클러스터 내에서만 노출되기 때문에 ClusterIP라고 칭한다.
    - 동일 클러스터라면, 한 Node에 있는 Pod이 다른 Node에 있는 Service에 직접 접근가능
    - Service name을 DNS alias처럼 사용가능
    - Service name 및 ip는 클러스터 내에서 고유하기 때문에, 서로 다른 Node의 Pod들 간 통신에서 Node의 IP,port를 신경쓸 필요없음. 이 때 Node간 통신은 K8s 시스템 컴포넌트가 처리해준다.
    - ClusterIP는 Service의 타입명이면서 동시에, Service에 할당되는 클러스터 내부용 Private IP를 의미하기도 한다.
        - **모든 타입의 Service는 Cluster IP(Private IP)를 가진다.** 헷갈리지 말자.
    
2. `NodePort` opens **a static port on each node's IP address**, routing traffic to the Service to the corresponding Pod. (ClusterIP 기능 포함)
    - 기능: Node(호스트) 외부에서 {NodeIP}:{NodePort}로 request할 때, nodePort->port(Service)->targetPort(Pod)로 이어지는 포트포워딩이 수행됨
    - 주 사용목적: 클러스터 외부와의 통신 관리
    - 부가목적: 클러스터 내부 Node 간 통신 관리
        - 클러스터 내부라면 Service IP(ClusterIP)로 직접 접근하면 되기 때문에, 이는 nodePort타입의 주 사용목적은 아니다.
        - 클러스터 내 여러 Node에 걸친 Pod들끼리도 직접접근이 가능한데 이건 비효율적이라 비권장인 것이고, 클러스터 내부 Service끼리는 직접 접근하는 것이 K8s의 장점이고 권장사항이다.
    - 따라서 필요에 따라 계층화된 아키텍처를 구성할 수 있으며, **일반적으로 클러스터 외부에 노출시킬 Service는 nodePort타입을 쓰고, 클러스터 내부용 Service는 ClusterIP타입을 쓴다.** 
    - nodePort의 range(default): 30000-32767
        - nodePort 1개는 Service 1개에 대응
        - 한 클러스터에서 2768개의 Service를 실행가능
        - 클러스터 외부에서 접근시, 아무 NodeIP로 접근해도 nodePort만 맞으면 지정된 Service->Pod으로 접근된다.
        - **Service가 실제 실행중인 Node를 알 필요없다.**
    - 문제점:
        - 외부에서 단일 Node IP를 지정하여 Service에 접근하고 있는 경우, 해당 Node에 문제발생시, Service는 다른 Node에 살아있어도 접근이 불가능해질 수 있다.
        - 상용 Service 배포시, 클라이언트는 안정적인 단일 엔드포인트(공인IP)로 접속하되, 이 트래픽이 여러 Node로 분산될 필요가 있다. 이를 해결해주는 것이 다음 나오는 LoadBalancer 타입 Service이다.
3. `LoadBalancer` allocates an **external IP address to the Service** to route traffic to the Pod, typically by using a cloud provider's load balancer.(NodePort 기능 포함)
    - 주 사용목적: 클라우드(AWS, GCP)를 이용해서 Service를 클러스터 외부의 인터넷에 노출
        - e.g.) 웹 서비스 배포
    - 왜 LoadBalancer인가?
        - 상용 Service배포시 nodePort 타입 Service의 문제점을 극복하기 위함
            - nodePort 타입 Service는 nodePort만 맞으면, 아무 Node나 하나 골라서 원하는 Service에 접근가능
            - 하지만 해당 Node가 죽어버리면, Service가 살아있어도 접근불가
        - 따라서, 클라이언트는 안정적인 단일 엔드포인트(공인IP)로 접속하되, 이를 통한 트래픽은 클러스터 내 여러 Node로 분산될 필요가 있다.
        - 이 때, 각 Node로 향하는 트래픽의 Load Balancing은 K8s로컬시스템이 아닌 클라우드 공급자가 담당
    - nodePort는 K8s관리자가 지정하지 않는다.
        - nodePort가 내부적으로 사용되는건 맞지만, 클라우드 공급자의 Load Balancer가 자동 할당 
        - 디폴트 range인 30000-32767 외에 다른 port도 사용 가능해서 보안적으로 더 좋다. 

- NodePort vs. LoadBalancer
    - 만약 클라우드가 아닌 가상환경 등 소규모 네트워크에서 LoadBalancer 타입을 쓴다면 NodePort 타입과 별 차이가 없다.
    - NodePort와 LoadBalancer 타입 둘 다 Service를 클러스터 외부로 노출시키려는 목적이 있으나, 약간 차이가 있다. 
        - LoadBalancer: 클라우드를 활용하여 서비스를 외부 노출 및 로드 밸런싱
        - NodePort:
            - 클러스터 외부 통신 (메인 목적)
                - 단순 외부 네트워크와 연결
                - 외부 "인터넷" 노출 시: 다음 설명할 ingress 사용
            - 클러스터 내부 통신 (부차적인 목적)
        - 즉, 일반적으로 k8s 서비스의 외부 인터넷 배포 방법
            - 클라우드 쓸거면 LoadBalancer
            - 그 외엔 nodePort+ingress
    
4. `ExternalName` is used to provide DNS aliases to external services.

```
# endpoint(ep): service로 포트포워딩된 대상 Pod(Container)의 IP와 port 출력
kubectl get endpoint 

# 특정 서비스의 대상 엔드포인트만 확인
kubectl get ep/{Service_name}
kubectl get ep {Service_name}
kubectl describe ep {Service_name}
```
# Ingress
- 외부 연결
- [Service 개념, 그림(특히 배포방법 및 LoadBalancer에 대한 설명이 좋음)](https://blog.eunsukim.me/posts/kubernetes-service-overview)
