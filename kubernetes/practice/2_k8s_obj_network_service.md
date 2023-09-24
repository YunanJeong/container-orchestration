# Service

- 쿠버네티스 Object 중 하나
- 구성한 App.(Pods)을 어떻게 네트워크에 노출시킬지 결정하는 Object
- Pod들의 클러스터 내외부 통신을 책임지는 Object
- Deployment와는 별개로, 네트워크 측면에서 Pods의 상위 layer라고 볼 수 있다.

```txt
This component acts as an abstract layer that exposes a set of Pods to the network as a single endpoint.

Services provide load balancing, service discovery, and other features to the Pods.

They allow network communication between the Pods and other components in the cluster, and abstract the underlying network topology.
```

## Service Type

- ClusterIP
- NodePort
- LoadBalancer
- ExternalName

### 주의사항

- Service Type과 별개로, ClusterIP, NodePort, LoadBalancer, ExternalName이라는 네트워크 구성요소들이 존재한다.

- Service와 깊게 연관된 네트워크 구성요소의 이름을 따서, Service Type 이름을 지은 것이다.

- e.g. 블로그 등에서 단순히 ClusterIP라고 칭할 때, 네트워크 요소인 ClusterIP인지, Service의 타입인 ClusterIP인지는 문맥에 따라 다르다. 구글링할 때 오인할만한 글, 그림 등이 종종 있기 때문에 헷갈리지 않도록 하자

## ServiceType: ClusterIP

`ClusterIP` is the default Service type and provides **a virtual IP address** inside the cluster to access the Pods.

### Cluster IP

- 모든 타입의 Service에 default로 할당되는 IP
- 클러스터 내에서만 접근가능한 Private IP
- `kubectl get svc`으로 확인가능

### 사용목적

- Pod들 간 클러스터 내부 통신 관리
- Service를 클러스터 내부 노출

### 기능&용례

- 클러스터 내부라면 어느 Node에서든 원하는 Service에 ClusterIP로 직접 접근가능
  - 여러 Node에 걸친 Pod들끼리 통신할 때 Node의 IP,port를 신경쓸 필요없음
  - 이 때 Node간 통신은 K8s시스템이 내부처리하며, 정해진 포트에 대해 사전 보안인가는 필요
- Cluster IP 대신, Service name을 DNS alias처럼 사용가능
  - Cluster IP 및 Service name은 클러스터 내에서 고유
- Service에 소속된 백엔드 Pods들 간 수신 트래픽을 분배하는 로드밸런싱이 기본 적용됨
  - kube-proxy에 의한 라운드로빈
  - NodePort, LoadBalancer 타입 및 Ingress에서 언급되는 외부트래픽 로드밸런싱과는 다름

### 참고

- ClusterIP 의미는 문맥따라 다름
  - ClusterIP 타입 Service
  - Service에 할당되는 클러스터 내부용 Private IP

- 후술할 `다른 타입의 Service들도 ClusterIP가 할당되며, ClusterIP Service 기능도 포함`한다.
- Pod에 private IP가 할당되는데, 굳이 또 다른 private IP인 Cluster IP로 내부통신하는 이유
  - Pod끼리 직접통신은 비권장 사항
  - Pod은 자주 재실행되므로 IP도 변경될 수 있음
  - 관리할 Pod 개수가 너무 많기 때문에, 묶어서 편하게 관리하기 위함
  - 로드밸런싱 등 효율적인 네트워크 자원 관리 가능

## ServiceType: NodePort

`NodePort` opens **a static port on each node's IP address**, routing traffic to the Service to the corresponding Pod.

### 사용목적

- 클러스터 외부와의 통신 관리
- Node의 port로 Service를 외부 노출

### 기능

- Node 외부에서 {NodeIP}:{NodePort}로 request할 때, nodePort->port(Service)->targetPort(Pod)로 이어지는 포트포워딩이 수행됨
- ClusterIP 기능 포함

### NodePort

- Node(호스트)의 port
- range(default): 30000-32767
- Service 1개를 특정 NodePort로 개방하면, **클러스터 내 모든 Node에서도 해당 Port를 점유**
  - 한 클러스터에서 NodePort 1개는 Service 1개에 대응
  - 한 클러스터에서 2768개의 NodePort Service 실행가능
- 클러스터 외부에서 접근시
  - 아무 NodeIP를 써도 NodePort만 맞으면 지정된 백엔드으로 라우팅됨 (NodePort->Service->Pod)
  - Client는 Service 프로세스가 실제 실행중인 Node를 알 필요없다.

### 참고

- NodePort 의미는 문맥따라 다름(가끔 블로그에 이상한 설명, 그림이 있음)
  - NodePort 타입의 Service
  - Node의 Port
- {NodeIP}:{NodePort}로 클러스터 내부통신도 가능, But, 주목적은 아님
  - 내부통신에는 ClusterIP 활용이 K8s 권장사항
- 필요에 따라 계층화된 아키텍처를 구성할 수 있으며, **일반적으로 클러스터 외부에 노출시킬 Service는 nodePort타입을 쓰고, 클러스터 내부용 Service는 ClusterIP타입을 쓴다.**

### 문제점

- 외부에서 단일 Node IP를 지정하여 Service에 접근하고 있는 경우, 해당 Node에 문제발생시, 다른 Node에 해당 Service가 살아있어도 접근이 불가능해질 수 있다.
- 상용 Service 배포시, 클라이언트는 안정적인 단일 엔드포인트(공인IP)로 접속하되, 이 트래픽이 여러 Node로 분산될 필요가 있다. 이를 해결해주는 것이 후술할 LoadBalancer 타입 Service이다.

## ServiceType: LoadBalancer

`LoadBalancer` allocates an **external IP address to the Service** to route traffic to the Pod, typically by using a cloud provider's load balancer.

### - 사용목적

- 클라우드(AWS, GCP)를 이용해서 Service를 클러스터 외부 노출 (e.g. 웹 서비스 배포)
- 로드밸런싱

### - 기능

- 클러스터 외부에 안정적인 단일 엔드포인트(External IP) 제공
  - 여기서 엔드포인트는 클라이언트가 접속시 직접사용하는 URL이 아니라 클러스터 쪽의 외부 엔드포인트를 의미한다.
  - LoadBalancer에 할당된 IP가 공인 IP라면 클라이언트 입장에서도 직접사용하는 엔드포인트라고 할 수 있다.
  - 이와 관련해서는 [LB타입 서비스 예제](https://github.com/YunanJeong/container-orchestration/blob/main/practice/service/3_svc-loadbalancer-redisdb-server.yml)의 LoadBalancerIP 및 externalIPs 관련 주석을 참고하자.

- 엔드포인트로 들어오는 트래픽을 각 Node 또는 Pod로 분산(로드밸런싱)
- ClusterIP, NodePort 기능 포함
  - LoadBalancer가 NodePort를 자동할당
  - 클라우드에서 제공하는 LoadBalancer는 디폴트 range(30000-32767) 외 다른 NodePort도 할당해서 보안상 더 좋음

### - LoadBalancer

- 외부 트래픽에 대해 로드밸런싱을 수행하는 주체
- 일반적으로 클라우드 공급자의 것을 활용
- `Service와 별도로 존재하는 Proxy 서버(중요)`
  - (LoadBalancer 타입의) Service는 설정만 있는 것이고, 실제 대부분 기능은 LoadBalancer에서 수행된다.
  - 별도 구축된 LB가 없으면 클러스터 내 가상 LB가 Pod로 실행되고 사실상 Nodeport와 동일하게 기능이 수행된다.(K8s 배포판마다 구현방식이 다름)
  - MetalLB와 같은 서드파티 LoadBalancer도 설치하면 동일 클러스터 내 다른 namespace에 LB기능을 구현한 Pod가 실행된다.

### - 참고

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

### Service Type - ExternalName

`ExternalName` is used to provide DNS aliases to external services.

```sh
# endpoint(ep): service로 포트포워딩된 대상 Pod(Container)의 IP와 port 출력
kubectl get endpoint 

# 특정 서비스의 대상 엔드포인트만 확인
kubectl get ep/{Service_name}
kubectl get ep {Service_name}
kubectl describe ep {Service_name}
```
