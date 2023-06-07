# minikube
## Installation
- 문서: [minikube 시작하기(공식)](https://minikube.sigs.k8s.io/docs/start/)
- 2코어, 2GB 메모리 필요
- VM or Container Runtime 필요
    - 도커 사용시 [도커를 non-root 권한으로 사용](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) 필요
    ```
    # 다운로드 및 설치
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    sudo dpkg -i minikube_latest_amd64.deb
    ```
## 참고 (minikube의 네트워크 구성, docker 기준 설명)
- minikube는 Localhost에서만 가능
- minikube는 단일 노드 클러스터만 지원(했었다.)
    - 노드 1개로 구성된 K8s 클러스터를 시뮬레이션
    - minikube 실행시 전체 k8s 시스템이 단 1개의 Container로 실행
    ```
    # minikube 실행
    minikube start

    # minikube 종료
    minikube stop

    # 클러스터 삭제(초기화)
    minikube delete
    ```
- [minikube의 멀티노드 클러스터(1.10.1 버전 이상)](https://minikube.sigs.k8s.io/docs/tutorials/multi_node/)
    - 다수 노드로 구성된 K8s 클러스터를 **1개의 머신에서** 시뮬레이션
    - **다수 머신은 minikube로 안된다!!(오해 ㄴㄴ!!)**
    - 공식 kubectl을 localhost에 설치해서 각 노드를 제어해야 함
    - ControlPlane과 Worker 노드들이 개별 Container로 구현됨
        - `docker ps` 및 `kubectl get nodes`로 확인가능
        - 개별 Pod(Container)는 노드Container 내부에서 실행됨
    ```
    # minikube Multi-node Cluster 실행
    minikube start --nodes {node개수} -p {Cluster 이름 지정}
    # minikube Multi-node Cluster 종료
    minikube stop -p {Cluster 이름 지정}
    ```
## Command
- `minikube kubectl -- `
    -  minikube의 서브커맨드로 일반적인 kubectl의 명령어를 실행 가능
    - `alias kubectl="minikube kubectl --"`를 `~/.bashrc`에 등록하여 편하게 쓰자
    - 단일 노드 전용
- `minikube ip`
    - minikube가 실행된 VM or Container의 IP를 반환
    - K8s 클러스터의 단일노드 ip를 의미
    - 멀티노드
        - default: Control Plane이 포함된 노드 IP를 반환
        - `--node={대상노드NAME}`: 대상 노드 IP 반환 
- `minikube service {service name}`
- `minikube service --all`
    - K8s에서 service마다 ip가 할당되는데, 이는 K8s 클러스터 환경 내 private ip이다.
    - minikube 사용시 localhost는 클러스터 외부이므로, 클러스터 내부 서비스에 접근하기 위한 tunnel을 생성해주는 명령어
    - minikube+도커 채택시 자주 사용됨
       - 가상 클러스터를 생성하기 위한 도구가 도커라면, 도커 브릿지 네트워크를 건너가기 위해 필요한 경우가 많다.
- `minikube dashboard`
    - k8s 대시보드 실행. 접속은 브라우저에서
    - 대시보드 자체는 minikube 전용이 아니라, 일반적인 k8s의 모니터링 대시보드
- `minikube addons`
    - minikube로 각종 K8s 애드온 활성화 용도 (dashboard, ingress controller 등)
    - 이 기능말고, kubectl로 K8s 자체기능으로 추가해도 된다.
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

# 리셋
sudo systemctl stop k3s
sudo rm -rf /var/lib/rancher/k3s/
sudo systemctl start k3s
```
## 참고
- K3s 프로세스는 daemon으로 실행된다.
- 클러스터 내 container는 containerd로 실행된다. (별도 설치 필요없음.default)

# Context 관리
- 컨텍스트(현재 kubectl 대상 클러스터) 전환하기
    - 이 때 kubectl은 `.kube/config`에 있는 파일을 참조하는 것이기 때문에, minikube든 k3s든 어떤 kubectl을 써도 상관없다.

    ```
    # 컨텍스트(클러스터) 목록 확인
    $ kubectl config get-contexts
    CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
              default    default    default
    *         minikube   minikube   minikube   default
    ```
    ```
    # 컨텍스트를 default로 변경
    CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
    *         default    default    default
              minikube   minikube   minikube   default
    ```
    ```
    # 컨텍스트를 minikube로 변경
    $ kubectl config use-context minikube
    CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
              default    default    default
    *         minikube   minikube   minikube   default
    ```

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
```
# namespace 목록 조회
kubectl get ns

# namespace에 속한 Object 조회
kubectl get all -n {namespace_name}
```

## Service
- This component acts as an abstract layer that exposes a set of Pods to the network as a single endpoint.
- Services provide load balancing, service discovery, and other features to the Pods.
- They allow network communication between the Pods and other components in the cluster, and abstract the underlying network topology.
- 구성한 App.(Pods)을 어떻게 네트워크에 노출시킬지 결정하는 Object
- Pod들의 클러스터 내외부 통신을 책임지는 Object
- Deployment와는 별개로, 네트워크 측면에서 Pods의 상위 layer라고 볼 수 있다.

### Service Type
### 1. `ClusterIP` is the default Service type and provides **a virtual IP address** inside the cluster to access the Pods.

#### - 사용목적
- Pod들 간 클러스터 내부 통신 관리
- Service를 클러스터 내부 노출
    
#### - Cluster IP
- 모든 타입의 Service에 default로 할당되는 IP
- 클러스터 내에서만 접근가능한 Private IP
- `kubectl get svc`으로 확인가능


#### - 기능&용례
- 클러스터 내부라면 어느 Node에서든 원하는 Service에 ClusterIP로 직접 접근가능
    - 여러 Node에 걸친 Pod들끼리 통신할 때 Node의 IP,port를 신경쓸 필요없음
    - 이 때 Node간 통신은 K8s시스템이 내부처리하며, 정해진 포트에 대해 사전 보안인가는 필요
- Cluster IP 대신, Service name을 DNS alias처럼 사용가능
    - Cluster IP 및 Service name은 클러스터 내에서 고유
- Service에 소속된 백엔드 Pods들 간 수신 트래픽을 분배하는 로드밸런싱이 기본 적용됨
    - kube-proxy에 의한 라운드로빈
    - NodePort, LoadBalancer 타입 및 Ingress에서 언급되는 외부트래픽 로드밸런싱과는 다름

#### - 참고
- ClusterIP 의미는 문맥따라 다름
    - ClusterIP 타입 Service
    - Service에 할당되는 클러스터 내부용 Private IP

- 후술할 `다른 타입의 Service들도 ClusterIP가 할당되며, ClusterIP Service 기능도 포함`한다.
- Pod에 private IP가 할당되는데, 굳이 또 다른 private IP인 Cluster IP로 내부통신하는 이유
    - Pod끼리 직접통신은 비권장 사항
    - Pod은 자주 재실행되므로 IP도 변경될 수 있음
    - 관리할 Pod 개수가 너무 많기 때문에, 묶어서 편하게 관리하기 위함
    - 로드밸런싱 등 효율적인 네트워크 자원 관리 가능
    
### 2. `NodePort` opens **a static port on each node's IP address**, routing traffic to the Service to the corresponding Pod. 
#### - 사용목적
- 클러스터 외부와의 통신 관리
- Node의 port로 Service를 외부 노출

#### - 기능
- Node 외부에서 {NodeIP}:{NodePort}로 request할 때, nodePort->port(Service)->targetPort(Pod)로 이어지는 포트포워딩이 수행됨
- ClusterIP 기능 포함

#### - NodePort
- Node(호스트)의 port
- range(default): 30000-32767
- Service 1개를 특정 NodePort로 개방하면, **클러스터 내 모든 Node에서도 해당 Port를 점유**
    - 한 클러스터에서 NodePort 1개는 Service 1개에 대응
    - 한 클러스터에서 2768개의 NodePort Service 실행가능
- 클러스터 외부에서 접근시
    - 아무 NodeIP를 써도 NodePort만 맞으면 지정된 백엔드으로 라우팅됨 (NodePort->Service->Pod)
    - Client는 Service 프로세스가 실제 실행중인 Node를 알 필요없다.

#### - 참고
- NodePort 의미는 문맥따라 다름(가끔 블로그에 이상한 설명, 그림이 있음)
    - NodePort 타입의 Service
    - Node의 Port
- {NodeIP}:{NodePort}로 클러스터 내부통신도 가능, But, 주목적은 아님
    - 내부통신에는 ClusterIP 활용이 K8s 권장사항
- 필요에 따라 계층화된 아키텍처를 구성할 수 있으며, **일반적으로 클러스터 외부에 노출시킬 Service는 nodePort타입을 쓰고, 클러스터 내부용 Service는 ClusterIP타입을 쓴다.**
    
#### - 문제점:
- 외부에서 단일 Node IP를 지정하여 Service에 접근하고 있는 경우, 해당 Node에 문제발생시, 다른 Node에 해당 Service가 살아있어도 접근이 불가능해질 수 있다.
- 상용 Service 배포시, 클라이언트는 안정적인 단일 엔드포인트(공인IP)로 접속하되, 이 트래픽이 여러 Node로 분산될 필요가 있다. 이를 해결해주는 것이 후술할 LoadBalancer 타입 Service이다.

### 3. `LoadBalancer` allocates an **external IP address to the Service** to route traffic to the Pod, typically by using a cloud provider's load balancer.
#### - 사용목적
- 클라우드(AWS, GCP)를 이용해서 Service를 클러스터 외부 노출 (e.g. 웹 서비스 배포)
- 로드밸런싱

#### - 기능
- 클러스터 외부 클라이언트에게 안정적인 단일 엔드포인트(External IP) 제공
- 엔드포인트로 들어오는 트래픽을 각 Node 또는 Pod로 분산(로드밸런싱)
- ClusterIP, NodePort 기능 포함
    - LoadBalancer가 NodePort를 자동할당
    - 클라우드에서 제공하는 LoadBalancer는 디폴트 range(30000-32767) 외 다른 NodePort도 할당해서 보안상 더 좋음

#### - LoadBalancer
- 외부 트래픽에 대해 로드밸런싱을 수행하는 주체
- 일반적으로 클라우드 공급자의 것을 활용
- `Service와 별도로 존재하는 Proxy 서버(중요)`
    - (LoadBalancer 타입의) Service는 설정만 있는 것이고, 실제 대부분 기능은 LoadBalancer에서 수행된다.
    - 해당 Service와 같은 클러스터 내 개별 Pod로 실행됨. 서드파티 LoadBalancer를 설치하면 동일 클러스터 내 다른 namespace를 쓰기도 한다.

#### - 참고
- LoadBalancer 의미는 문맥따라 파악
    - (Service 타입 중 하나인) LoadBalancer
    - (로드밸런싱을 수행하는 Entity인) LoadBalacer
- `LoadBlancer 타입은 원래 로드밸런싱을 목적으로 만들어졌으나, 클라우드 전용 기능처럼 사용`되고 있음
- `베어메탈 환경에서 LoadBalancer Service를 사용가능하지만 의미없거나 비효율적`인 경우가 많음
    - Service는 App단의 설정이므로, 별도 네트워크 인프라 작업 필요
        - e.g. External IP를 Service에 설정하더라도, 이를 실제 사용하려면 해당 IP를 공인 IP로 준비하거나, 엔드포인트 IP로서 통신가능한 환경을 구축해야 함
        - e.g. LoadBlancer (Proxy 서버) 별도 구성 필요
        - e.g. 베어메탈용 LoadBlancer로 대표적인 서드파티 앱(MetalLB)이 있으나 호환성이 좋지 않음
    - 이에 따라 관리&운영이 복잡해지고, 확장성&가용성 떨어짐
    - 소규모 환경에선 노드가 적으므로 NodePort타입 사용과 별반 차이 없음
    - 대규모 환경에서 인프라 작업하느니 차라리 클라우드 쓴다. K8s 관리자(container orchestration)의 영역을 넘어선다.

- [Service 개념, 그림(특히 배포방법 및 LoadBalancer에 대한 설명이 좋음)](https://blog.eunsukim.me/posts/kubernetes-service-overview)

    
### 4. `ExternalName` is used to provide DNS aliases to external services.

```
# endpoint(ep): service로 포트포워딩된 대상 Pod(Container)의 IP와 port 출력
kubectl get endpoint 

# 특정 서비스의 대상 엔드포인트만 확인
kubectl get ep/{Service_name}
kubectl get ep {Service_name}
kubectl describe ep {Service_name}
```
## Ingress (입구, 인바운드)
- Service에 대한 클러스터 외부접근을 관리하는 API Object
- Ingress Controller가 실제 기능을 수행하는 주체이고, Ingress는 수행 규칙을 정의&선언하는 Object 

- 사용 목적
    - 클러스터 외부에 http/https를 열어주기 위해 쓰임
    - *Service를 외부망에 배포*하기 위해 사용
        - e.g. 한 클러스터에 여러 Service를 운용중인 경우, 각 Service에 연동된 모든 nodePort를 사용자에게 알려주기는 힘듦
        - 따라서 외부접근시 *http/https(80/443)와 같은 일반포트를 공용*으로 쓰게하고, *사용된 URL에 따라 각기 다른 Service로 라우팅*되도록 설정할 필요있음
        
### Ingress Controller
- Ingress는 다른 Object와 달리 별도 Controller 설치 필요
- Ingress Controller가 외부 트래픽을 클러스터 내 Service로 라우팅하는 Proxy 역할
- 실사용시 클러스터(namespace 'ingress-nginx') 내 개별 Pod 및 Service(LoadBalancer)로서 워커 노드 측에서 실행된다.
- Nginx, Traefik, and Istio 등 여러가지 있음
- 설치방법은 K8s 배포판이나 Ingress Controller 종류에 따라 다르다. 대부분 Yaml이 제공된다.
- Controller 종류에 따라 내부 구현 방식이 다양하다.

### Ingress 설정 순서
1. ingress controller 설치
    ```
    # 일반적인 nginx ingress controller 배포 (Yaml 메니페스트로 배포)
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml

    # 실행 확인
    kubectl get all -n ingress-nginx
    ```
    ```
    # minikube 한정 ingress 활성화
    minikube addons enable ingress
    minikube service ingress-nginx-controller -n ingress-nginx --url # (minikube에서 docker 사용시) nginx 포트 개방
    ```
2. (설치한 ingress controller의 설정과 외부 트래픽 처리규칙을 담은)ingress 설정파일 apply
    ```
    kubectl apply -f {ingress파일명.yml}

    # 인그레스 정보 확인
    kubectl get ingress
    ```
3. 접속할 클라이언트에서 hosts 파일 수정
    - 윈도우(`C:\Windows\System32\drivers\etc\hosts`)
    - 리눅스(`/etc/hosts`)
    ```
    # IP대신 도메인 네임을 사용할 경우 다음과 같은 내용을 추가
    # X.X.X.X는 실제 사용될 IP
    X.X.X.X example1.mydomain.com
    X.X.X.X example2.mydomain.com
    ```


## NodePort vs. LoadBalancer vs. Ingress (K8s App. 외부 네트워크 노출 3가지 방법 비교)
- 요약
    - 내부망에서 간단히 배포할거면 nodePort
    - 외부망 배포: LoadBalancer or Ingress
    - 클라우드 쓸거면: LoadBalancer
    - 80/443포트(http/https)로 노출: ingress
    - http/https가 아니면: nodePort or LoadBalancer

- NodePort vs. LoadBalancer
    - 만약 클라우드가 아닌 가상환경 등 소규모 네트워크에서 LoadBalancer 타입을 쓴다면 NodePort 타입과 별 차이가 없다.
    - LoadBalancer
        - 클라우드를 활용하여 서비스를 외부 노출
        - 로드 밸런싱(공인IP<=>각 노드들 사이 트래픽 분산)
    - NodePort
        - 단순 외부 네트워크와 연결
        - 외부망 "인터넷" 노출 시엔 port가 드러나므로 부적절

- LoadBalancer vs. Ingress
    - 둘 다 외부노출용
    - Ingress
        - 앱 수준에서 라우팅(L7, Application Layer)
        - url 주소로 트래픽 구분
        - 주로 http/https 처리에 사용
        - http/https가 아닌데 외부 인터넷에 노출시키려면 NodePort or LoadBalancer사용
    - LoadBalancer
        - 네트워크 수준에서 라우팅 (L4, Transport Layer)
        - IP와 Port로 트래픽 구분
        - 간혹 IP 사용 및 네트워크 수준이라고 해서 Network Layer라고 하는 글들이 있는데 잘못된 표현
        - K8s의 LoadBalancer는 Transport Layer(L4)에서 동작한다고 표현하는 것이 맞다.
        - [오라클 피셜](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer.htm)
        - 클라우드 사용시 활용

### (의문점)Ingress에다가 NodePort 또는 LoadBalancer를 반드시 함께 사용해야한다는 블로그 자료들이 많던데, 막상 실행해보니 ClusterIP Service도 Ingress로 외부노출이 가능하다. 팩트가 무엇인가?

#### 답변
- `Ingress는 ClusterIP를 포함해서 어떤 타입의 Service에도 붙일 수 있고, 외부망 배포가 가능하다.`
- 가장 많이 사용되는 Nginx Ingress Controller는 ClusterIP Service를 외부 노출 가능
    - e.g. [Cluster IP 서비스로 Ingress](https://github.com/kubernetes/kubernetes/issues/26508)
- 일부 클라우드 공급자의 Ingress Controller를 사용하는 경우, ClusterIP를 지원하지 않는 경우가 있을 수 있다.
    - e.g. [GKE](https://stackoverflow.com/questions/58314207/why-cant-i-attach-a-service-type-clusterip-to-ingress-on-gke)
- Ingress Controller마다 구현방식이 다양하기 때문에 이 부분 설명은 케바케가 될 수 있음
- 그러나 `K8s 공식 Ingress 사양에서는 따로 특정 타입의 Service를 요구하지 않는다.`

#### - 사람들이 오해하는 이유 1
#### 공식적으로 Ingress와 함께 언급되는 LoadBalancer에 대한 오해
- 이는 Ingress-Managed LoadBalancer를 의미
- App(L7) 단위의 트래픽을 분산시켜주는 프록시 서버
- [공홈](https://kubernetes.io/ko/docs/concepts/services-networking/ingress/)의 설명에서는 Service(LoadBalancer 타입)과는 분명히 구분하고 있다.

#### - 사람들이 오해하는 이유 2
#### NodePort, LoadBalancer 용어에 대한 오해
- Ingress 사용시, 어쨌든 외부에서 클러스터에 접근하려면 가장먼저 Node의 Port를 통해야하고, 클라우드 사용시 외부 LoadBalancer를 사용할 수 있어야 한다.
- 이런 기능들을 구현한 Ingress Controller 내부 컴포넌트가 있을 것이다.
- 그렇다고 이것이 K8s 관리자가 배포하려는 App Service를 NodePort or LoadBalancer 타입으로 만들어한다는 말은 아니다.

#### - 가장 널리 쓰이는 Nginx Ingress Controller의 사례
- Nginx Ingress Controller 구성시 자동으로 별도 namespace에 'LoadBalancer 타입의 Service'가 생성된다.
- 이는 Nginx에서 Controller 자체 기능구현을 위해 다음과 같이 K8s의 Service(LoadBalancer)기능을 활용하는 것이다.
    - App 외부노출 기능을 구현하기 위해 NodePort or LoadBalancer 타입의 Service 설정
    - K8s 관리자로 하여금 ingress 설정만으로 클라우드 공급자의 LoadBalancer를 활용할 수 있도록 하기 위해 LoadBalancer 타입의 Service 설정
- 이를 두고 각종 설명글, 그림에서는 'LoadBalancer 타입의 Service를 활용해야만 한다'라고 표현하고 있으나 이는 Ingress Controller 내부구조에 한정된 것이지,
- K8s 관리자가 배포하고자 하는 App Service를 LoadBalancer 타입으로 설정해야하는 것은 아니다. App Service는 ClusterIP 타입이어도 상관없다!!
- 작업 환경이나 Ingress Controller 종류에 따라 더 세밀한 네트워크 제어를 위해, K8s 관리자가 직접적으로 LoadBalancer 타입의 Service를 추가하여 Controller의 일부기능을 구현할 수는 있으나, 그 Service가 백엔드 App Service를 의미하는 것은 아니다.

- 2020년 블로그들[[1]](https://5equal0.tistory.com/entry/Kubernetes-Nginx-Ingress-Controller)[[2]](https://zgundam.tistory.com/178)을 보면 nginx controller인데도 App Service를 클라우드, 베어메탈 환경을 구분해서 LoadBalancer, NodePort타입으로 생성해줘야 된다고 하는데, 현재는 그냥 ClusterIP로만 생성해도 잘만 된다... nginx ingress controller가 패치된 것일 수도 있겠다.

- 다시 한번 말하자면 `Ingress는 ClusterIP를 포함해서 어떤 타입의 Service에도 붙일 수 있다.`
- 일반적인 Controller나 Nginx Controller를 쓰고 있다면, `일부러 배포하고자 하는 App Service를 NodePort나 LoadBalancer 타입으로 만들 필요는 없다.`
