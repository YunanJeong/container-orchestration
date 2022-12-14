# K8s

# 종류
## 공식 kubernetes(K8s)
    - Apache 2.0 License
    - 관리: CNCF(Cloud Native Computing Foundation, Google참여)
    - Google이 개발 후 CNCF재단에 기부해서 오픈소스화 됨
## Managed K8s Service
    - AWS(EKS), Azure(AKS), GCP(GKE)와 같은 클라우드 기반 서비스 (CaaS), (IaaS와 PaaS 사이)

## 경량 배포판(distributions)
- 구현체(implemetations)라는 표현도 가끔 쓰지만, 보통은 K8s 배포판(distributions)이라고 불림
- [MicroK8s vs. K3s vs. minikube 비교표](https://microK8s.io/compare)
- [minikube, k3s, 오리지널K8s 특징 및 설치](https://www.samsungsds.com/kr/insights/kubernetes-2.html?moreCnt=0&backTypeId=&category=)
- K8s 설치 및 구성이 복잡해서, 편하게 사용하기 위한 배포판(or 관리도구)들이 있음
- 단, 오리지널 K8s만큼의 성능을 쓸 수는 없고, 목적에 맞게 사용하는 도구라고 봐야 함
- 주요 목적: 학습용, 빠른 환경 구성, 가벼움
    - (e.g. IoT, 라즈베리파이 등에서도 가능)
- minikube (미니큐브)
    - is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.
    - 제공: SIG(Special Interest Group, **쿠버네티스 개발자들** 중 특정 주제에 관심있는 개발자모임)
    - **유일하게 K8s 공식문서에서도 다뤄짐**. 다른 배포판은 다른 기관에서 제공
- k3s (by *Lancher Labs* 기업)
- k3d: Docker Container안에 k3s가 설치되어 배포되는 형태
- MicroK8s (by *Canonical*, Ubuntu Publisher 기업)
- Rancher (by *Lancher Labs* 기업)
    - 오픈소스버전, 상용버전 별도 존재
    - 용도: 대규모 및 기업용 환경에서도 활용 가능한 다목적 쿠버네티스 관리 플랫폼
    - 장점: 기본 포함된 기능이 많고 추가 도구 설치도 쉬움. 멀티 클라우드 관리 가능
    - 단점: 다른 도구에 비해 무거움

# 설치 (공식 K8s)
- [설치하기 전 쿠버네티스 컴포넌트 관련 설명 참고](https://kubernetes.io/ko/docs/setup/)

- 배포도구
    - 공식지원: kubeadm
    - [배포도구로 쿠버네티스 설치하기(공식)](https://kubernetes.io/ko/docs/setup/production-environment/tools/)

    - [쿠버네티스 기초학습(공식), 웹 기반 대화형 터미널+Minikube](https://kubernetes.io/ko/docs/tutorials/kubernetes-basics/)

# 용어
## Kubernetes(쿠버네티스)
	- 약어: K8s(케이츠, 케이에이츠), kube(큐브)
	- Container Orchestration Tool의 사실상 표준
	- 구글에서 만듦
## kubeadm
## kubelet
## containerd(컨테이너-디=>d는 daemon을 의미)
- Container Runtime 중 하나
- Docker에서 Container 표준을 지키면서 만든 Container Runtime
- 일반적으로 Docker와 동의어다. 굳이 Docker상표, Docker Engine과 구분해서 Container Runtime을 정확히 지칭할 때 사용되는 단어
- [containerd는 무엇이고 왜 중요할까?](https://www.linkedin.com/pulse/containerd%EB%8A%94-%EB%AC%B4%EC%97%87%EC%9D%B4%EA%B3%A0-%EC%99%9C-%EC%A4%91%EC%9A%94%ED%95%A0%EA%B9%8C-sean-lee/?originalSubdomain=kr)
## etcd(엣시디)
- K8s에서 사용하는 Storage
- 분산된 시스템 또는 클러스터의 설정 공유, 서비스 검색 및 스케줄러 조정을 위한 일관된 오픈소스, 분산형 키-값 Storage
- [etcd란?](https://www.redhat.com/ko/topics/containers/what-is-etcd)
## Control Plane
- 클러스터를 내부 조율 및 관리하는 Server
- App에 대해 각각 스케쥴링, 항상성 유지, 스케일링, Rolling Out(변경사항을 순서대로 반영) 등 처리
- Node는 컨트롤 플레인이 제공하는 쿠버네티스 API를 통해서 컨트롤 플레인과 통신
- 최종 사용자도 쿠버네티스 API를 사용해서 클러스터와 직접 상호작용(interact) 가능
## Node
- App을 구동하는 Worker
- K8s 클러스터 내 Worker 머신으로 작동하는 VM or 물리적인 컴퓨터
## kubectl (kube-control)
- K8s 관리도구, Client CLI
## Deployment
- Container가 어떻게 배포되고 관리될지에 대한 설정을 가진 오브젝트
- 컨트롤 플레인이 Deployment 설정을 참조하여 App 및 Container를 배포&관리한다.
- 머신의 장애나 정비에 대응할 수 있는 자동 복구(self-healing) 메커니즘을 제공
- kubectl로 Deployment를 생성 및 관리할 수 있다.
## Object
- K8s 시스템에서 Entity(최소의 기능을 하는 단위)를 칭하는 단어. e.g.) Pod, Service Controller 등의 인스턴스들
- 오브젝트는 같은 네임스페이스에서 같은 종류 오브젝트가 다수 존재할 경우 이 오브젝트들은 각각 다른 이름을 가져야만 한다.
## Pod
- Container 1개 이상의 묶음
- K8s App의 최소단위
- [Pod 정의 및 굳이 Pod 컨셉을 쓰는 이유](https://www.redhat.com/ko/topics/containers/what-is-kubernetes-pod)
## Application
- K8s 공식 설명 중 자주 언급되는데, 각 Container를 지칭한다고 봐도 무방하다.

## 쿠버네티스 컴포넌트
- Control Plane 컴포넌트
    - kube-apiserver: 쿠버네티스 클러스터로 들어오는 요청을 가장 앞에서 접수하는 역할. 컨트롤 플레인의 프론트엔드
    - etcd
    - kube-scheduler: 스케줄링 담당 컴포넌트(새로 생성된 파드를 감지하여 어떤 노드로 배치할지 결정하는 작업)
- Node 컴포넌트
    - kubelet: 노드에서 컨테이너가 동작하도록 관리해 주는 핵심 요소
    - container runtime: 컨테이너 실행도구 e.g. Docker containerd
    - kube-proxy: 쿠버네티스 클러스터 내부에서 네트워크 요청을 전달하는 역할
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