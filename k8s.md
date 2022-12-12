# k8s

# 종류
- 공식 kubernetes(k8s)
    - Apache 2.0 License
    - 관리: CNCF(Cloud Native Computing Foundation, Google참여)
    - Google이 개발 후 CNCF재단에 기부해서 오픈소스화 됨
- Managed k8s Service
    - AWS(EKS), Azure(AKS), GCP(GKE)와 같은 클라우드 기반 서비스 (CaaS), (IaaS와 PaaS 사이)

- 경량 배포판
    - [MicroK8s vs. K3s vs. minikube 비교표](https://microk8s.io/compare)
    - [minikube, k3s, 오리지널k8s 특징 및 설치](https://www.samsungsds.com/kr/insights/kubernetes-2.html?moreCnt=0&backTypeId=&category=)
    - k8s 설치 및 구성이 복잡해서, 편하게 사용하기 위한 배포판(or 관리도구)들이 있음
    - 단, 오리지널 k8s만큼의 성능을 쓸 수는 없고, 목적에 맞게 사용하는 도구라고 봐야 함
    - 주요 목적: 학습용, 빠른 환경 구성, 가벼움
        - (e.g. IoT, 라즈베리파이 등에서도 가능)
    - minikube
        - is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.
        - 제공: SIG(Special Interest Group, **쿠버네티스 개발자들** 중 특정 주제에 관심있는 개발자모임)
        - **유일하게 k8s 공식문서에서도 언급**. 다른 배포판은 다른 기관에서 제공
    - k3s (by *Lancher Labs* 기업)
    - k3d: Docker Container안에 k3s가 설치되어 배포되는 형태
    - MicroK8s (by *Canonical*, Ubuntu Publisher 기업)
- Rancher (by *Lancher Labs* 기업)
    - 오픈소스버전, 상용버전 별도 존재
    - 용도: 대규모 및 기업용 환경에서도 활용 가능한 다목적 쿠버네티스 관리 플랫폼
    - 장점: 기본 포함된 기능이 많고 추가 도구 설치도 쉬움. 멀티 클라우드 관리 가능
    - 단점: 다른 도구에 비해 무거움

# 설치 (공식 k8s)
- [설치하기 전 쿠버네티스 컴포넌트 관련 설명 참고](https://kubernetes.io/ko/docs/setup/)

- 배포도구
    - 공식지원: kubeadm
    - [배포도구로 쿠버네티스 설치하기(공식)](https://kubernetes.io/ko/docs/setup/production-environment/tools/)


