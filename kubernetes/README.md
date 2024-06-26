# Kubernetes(쿠버네티스, K8s, 케이에이츠)

- Apache 2.0 License
- 관리: CNCF(Cloud Native Computing Foundation, Google참여)
- Google이 개발 후 CNCF재단에 기부해서 오픈소스화 됨

## 설치 (공식 K8s, 업스트림 쿠버네티스)

- **공식버전보다는 후술할 배포판을 목적에 맞게 설치 권장**
- [설치하기 전 쿠버네티스 컴포넌트 관련 설명 참고](https://kubernetes.io/ko/docs/setup/)

- 배포도구
  - 공식지원: kubeadm
  - [배포도구로 쿠버네티스 설치하기(공식)](https://kubernetes.io/ko/docs/setup/production-environment/tools/)

  - [쿠버네티스 기초학습(공식), 웹 기반 대화형 터미널+Minikube](https://kubernetes.io/ko/docs/tutorials/kubernetes-basics/)

## K8s 배포판(distributions)

- 또는 구현체(implementations)
- K8s 설치 및 구성이 복잡해서, 편하게 사용하기 위한 배포판(or 관리도구)들이 있음
- 단, 오리지널 K8s만큼의 성능을 쓸 수는 없고, 목적에 맞게 사용하는 도구들
- [MicroK8s vs. K3s vs. minikube 비교표](https://microK8s.io/compare)
- [minikube, k3s, 오리지널K8s 특징 및 설치](https://www.samsungsds.com/kr/insights/kubernetes-2.html?moreCnt=0&backTypeId=&category=)

### 경량

- 주요 목적: 학습용, 빠른 환경 구성, 가벼움
  - (e.g. IoT, 라즈베리파이 등에서도 가능)
- `minikube (미니큐브)`
  - is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.
  - 제공: SIG(Special Interest Group, **쿠버네티스 개발자들** 중 특정 주제에 관심있는 개발자모임)
  - **유일하게 K8s 공식문서에서 다뤄짐**. 다른 배포판은 다른 기관에서 제공
  - 테스트나 개발 용도에 적합
- `k3s` (by *Rancher Labs(SUSE)* 기업)
  - minikube와 마찬가지로 경량이나, minikube보다 **production ready**로 적합하다는 의견이 많음
- k3d
  - Docker Container안에 k3s가 설치되어 배포되는 형태
  - 단일 PC에서 다수 클러스터 상황을 시뮬레이션하고 싶을 때 사용
- MicroK8s (by *Canonical*, Ubuntu Publisher 기업)

### 대규모

- Rancher (by *Rancher Labs(SUSE)* 기업)
  - 오픈소스버전, 상용버전 별도 존재
  - 용도: 대규모 및 기업용 환경에서도 활용 가능한 다목적 쿠버네티스 관리 플랫폼
  - 장점: 기본 포함된 기능이 많고 추가 도구 설치도 쉬움. 멀티 클라우드 관리 가능
  - 단점: 다른 도구에 비해 무거움
- kubeadm (업스트림 쿠버네티스)
  - 쿠버네티스 공식
  - 마스터노드에 접근할 kubectl
  - 워커노드에 kubelet 함께 설치 필요

### Managed K8s Service

- AWS(EKS), Azure(AKS), GCP(GKE)와 같은 클라우드 기반 서비스
- CaaS (IaaS와 PaaS 사이)라고 칭한다.

## 용어

### Kubernetes(쿠버네티스)

- 약어: K8s(케이츠, 케이에이츠), kube(큐브)
- Container Orchestration Tool의 사실상 표준
- 구글에서 만듦

### containerd(컨테이너-디=>d는 daemon을 의미)

- Container Runtime 중 하나
- Docker에서 Container 표준을 지키면서 만든 Container Runtime
- 일반적으로 Docker와 동의어다. 굳이 Docker상표, Docker Engine과 구분해서 Container Runtime을 정확히 지칭할 때 사용되는 단어
- [containerd는 무엇이고 왜 중요할까?](https://www.linkedin.com/pulse/containerd%EB%8A%94-%EB%AC%B4%EC%97%87%EC%9D%B4%EA%B3%A0-%EC%99%9C-%EC%A4%91%EC%9A%94%ED%95%A0%EA%B9%8C-sean-lee/?originalSubdomain=kr)

### Control Plane (Master Node)

- 클러스터를 내부 조율 및 관리하는 Server
- App에 대해 각각 스케쥴링, 항상성 유지, 스케일링, Rolling Out(변경사항을 순서대로 반영) 등 처리
- Node는 컨트롤 플레인이 제공하는 쿠버네티스 API를 통해서 컨트롤 플레인과 통신
- 최종 사용자도 쿠버네티스 API를 사용해서 클러스터와 직접 상호작용(interact) 가능

### Node (Worker Node)

- App을 구동하는 Worker
- K8s 클러스터 내 Worker 머신으로 작동하는 Host(VM or 물리적인 컴퓨터)

### Application

- K8s 공식 설명 중 자주 언급되는데, 1개 이상의 Container 또는 Pod들의 집합을 지칭한다고 봐도 무방하다.
- 다수 Pod들을 용도에 따라 구분하여 칭할 때 사용
- Service 오브젝트 등 다른 리소스들을 포함하는 개념으로 사용될 수도 있다.

## 용어2 - 쿠버네티스 컴포넌트

### Control Plane 컴포넌트

- Controller: 클러스터가 원하는 상태(Desired State)를 유지하도록 지속적으로 변경사항을 확인
- API server: 쿠버네티스 클러스터로 들어오는 요청을 가장 앞에서 접수. 컨트롤 플레인의 프론트엔드
- etcd: Key-Value형태로 저장하는 스토리지. 어떤 리소스가 어떤 상태인지 기록. 분산처리시스템(e.g. ElasticSearch)에 종종 탑재된다.
- Scheduler: 스케줄링 담당 컴포넌트(새로 생성된 파드를 감지하여 어떤 노드로 배치할지 결정하는 작업)

### Node 컴포넌트

- kubelet: Control Plane과 Node 간 브릿지 역할. Node 쪽에서 실행됨
- container runtime: 컨테이너 실행도구. Node쪽에 Container가 실행되야 하니까 필요
- kube-proxy: K8s 클러스터에서 네트워크 연결 관리, API server와 통신하면서 네트워크 관리 방법을 전달받음 (각 라우팅 책임)

### kubectl (kube-control)

- K8s 관리도구, Client CLI

### etcd(엣시디)

- K8s에서 사용하는 Storage
- 분산된 시스템 또는 클러스터의 설정 공유, 서비스 검색 및 스케줄러 조정을 위한 일관된 오픈소스, 분산형 키-값 Storage
- [etcd란?](https://www.redhat.com/ko/topics/containers/what-is-etcd)

### kubelet

- Control Plane과 Node들 간 bridge 역할을 수행하는 경량 프로세스
- 각 Node Side에서 실행되는 agent
- 클러스터 내 노드들의 상태를 유지, 관리(시작, 종료, 모니터링 등 역할 포함)

## 용어3 - 오브젝트(리소스)

### Object

- K8s 시스템에서 Entity(최소의 기능을 하는 단위)
  - e.g. Pod, Service Controller 등의 인스턴스들
- 같은 네임스페이스에서 같은 타입의 Object가 다수 존재할 경우 각 Obejct들은 서로 다른 이름을 가져야만 한다.

### Resource

- K8s API(kubectl 등)으로 다루는 모든 대상
- Resource는 Computing, Stroage, and Network Resource 등을 포괄한다.
- Object vs. Resource
  - 혼용돼서 자주 사용되나, 차이가 있는 용어이긴 하다.
  - OOP의 Class-Object 관계와 거의 같다.
  - Object:  e.g. 1번 pod, 2번 pod 등 각각의 Instance들
  - Resource: e.g. pods, deployments, nodes, namespaces, services, persistent volumes 등

### Pod

- Container 1개 이상의 묶음 Object
- K8s App의 최소단위
- [Pod 정의, 굳이 Container 외에 Pod 컨셉을 쓰는 이유](https://www.redhat.com/ko/topics/containers/what-is-kubernetes-pod)
- 보통은 Container 1개 = Pod 1개로 쓰는 경우가 많다.
- 1 Pod에 여러 Container가 있는 경우, localhost 네트워크와 디렉토리를 공유한다.

### Deployment

- Container, Pod 배포&관리 방법에 대한 설정을 가진 Object
- 컨트롤 플레인이 Deployment 설정을 참조하여 App 및 Container를 배포&관리한다.
- 머신의 장애나 정비에 대응할 수 있는 자동 복구(self-healing) 메커니즘을 제공
- kubectl로 Deployment를 생성 및 관리 가능

### Service

- Container, Pod의 네트워크 노출 방법에 대한 설정을 가진 Object
