# EKS에서 앱 외부노출 방법 (AWS Load Balancer Controller)

## AWS Load Balancer Controller 사전 설치 필요

- AWS 서비스 중 하나인 Elastic LoadBalancer를 생성하기 위한 Controller
- EKS에서 LoadBalancer Service 및 Ingress 기능을 실제 구현하기 위해 사용된다.
- `Controller 설치 후 클러스터 내 실제 Pod 형태로 확인가능`하며, 해당 Pod는 Elastic LoadBalancer 서비스에 접근가능한 IAM Role을 가져야 한다.
- 따라서 설치과정에 `IAM Role(Policy)설정`과 `Pod배포 과정`이 포함된다.
  - IAM Role을 생성하기 위해 awscli를 쓰는데, 이 때 awscli의 액세스키에는 IAMFullAccess 권한이 있어야 한다.
  - Pod 배포엔 eksctl, Helm 등 여러 방법이 사용될 수 있다. namespace kube-system에 한 번 설치후 업데이트전 까지 영구사용한다.
- [설치방법 문서](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html)를 따라하면 어렵지 않다.

### 참고: Cloud Controller Manager vs. AWS Load Balancer Controller

- [잘 정리된 글](https://baptistout.net/posts/two-kubernetes-controllers-for-managing-aws-nlb/)
- `Cloud Controller Manager(kube-controller-manager)`
  - Legacy
  - 클라우드 기능(AWS, GCP, Azure 등)을 제공하기 위해 업스트림 쿠버네티스에 포함된 도구라서, `in-tree` controller라고 칭해짐
- `AWS Load Balancer Controller`
  - Latest
  - AWS 특화기능 제공
  - 쿠버네티스 입장에선 별도 툴이기 때문에 `out-of-tree` controller라고 칭해짐
  - helm,kubectl,eksctl 등으로 클러스터 내 Pod로 배포됨
  - 구 버전 이름: AWS Ingress Controller

## Service(Type: LoadBalancer)로 배포

- annotations 추가

```yaml
apiVersion: xxxxxxxxx
kind: Service
spec:
  type: LoadBalancer
metadata:
  annotations:
    # Controller v2.7 기준 최소 설정
    service.beta.kubernetes.io/aws-load-balancer-type: "external"  # 버전마다 입력값 종종 다름
    # service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance"  # default
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"  # default: internal(VPC)

    # 전용 Managed 보안그룹(inbound) 설정
    service.beta.kubernetes.io/load-balancer-source-ranges: "10.0.0.1/24, 198.168.0.1/24"
    # 특정 보안그룹 추가 (다른 Managed 보안그룹 무시됨)
    # service.beta.kubernetes.io/aws-load-balancer-security-groups: "sg-xxxxx"
    (...)
```

## Ingress로 배포

두 가지 방법이 있음. 장단점이 다양. 용도에 따른 선택

- instance type이 default라서 좀 더 보편적으로 쓰이고, AWS 각 서비스와 호환성이 좋다고 함. 단, 배포된 서비스 많으면 클러스터 내부의 iptables 부하 이슈 등 가능성...
- ip type은 속도가 빠르고, 보안 이슈 있음

### 방법1 (target-type: instance)

- annotations 추가
- ingress로 접근할 Pod는 NodePort 서비스로 배포되어있어야 함
- 로드밸런서가 자동생성된 후, 할당된 Public DNS를 ingress 속성에 등록(helm upgrade)

```yaml
apiVersion: xxxxxxxxxxxxxx
kind: Service
spec:
  type: NodePort
(...)
---
apiVersion: xxxxxxxxxxxxxx
kind: Ingress
metadata:
  annotations:
    # Controller v2.7 기준 최소 설정
    kubernetes.io/ingress.class: alb  # 또는 "spec.ingressClassName: alb" 불가
    alb.ingress.kubernetes.io/scheme: internet-facing  # default: internal

    # 전용 Managed 보안그룹(inbound) 설정
    alb.ingress.kubernetes.io/inbound-cidrs: "10.0.0.1/24, 198.168.0.1/24"
    # 특정 보안그룹 추가 (다른 Managed 보안그룹 무시됨)
    # service.beta.kubernetes.io/aws-load-balancer-security-groups: "sg-xxx,sg-xxx2"  
    (...)

spec:
  rules:
    # 로드밸런서에 할당된 DNS를 여기 입력 후 다시 helm upgrade
    - host: XXXXXXXXXXXXXXXXXXXXXXXXXXXX.elb.amazonaws.com
      http:
        paths:
          - path: /my-service
            pathType: Prefix
            backend: my-service
    (...)
```

### 방법2 (target-type: ip)

- 아래 예시처럼 ingress의 annotation 최소설정 필요
- 로드밸런서가 자동생성된 후, 할당된 Public DNS를 ingress 속성에 등록(helm upgrade)

```yaml
apiVersion: xxxxxxxxxxxxxx
kind: Ingress
metadata:
  annotations:
    # Controller v2.7 기준 최소 설정
    kubernetes.io/ingress.class: alb  # 또는 "spec.ingressClassName: alb"
    alb.ingress.kubernetes.io/scheme: internet-facing    # default: internal
    alb.ingress.kubernetes.io/target-type: ip            # default: instance

    # 전용 Managed 보안그룹(inbound) 설정
    alb.ingress.kubernetes.io/inbound-cidrs: "10.0.0.1/24, 198.168.0.1/24" 
    # 특정 보안그룹 추가 (다른 Managed 보안그룹 무시됨)
    # alb.ingress.kubernetes.io/security-groups: "sg-xxxx, nameOfSg1, nameOfSg2"
    (...)

spec:
  rules:
    # 로드밸런서에 할당된 DNS를 여기 입력 후 다시 helm upgrade
    - host: XXXXXXXXXXXXXXXXXXXXXXXXXXXX.elb.amazonaws.com
      http:
        paths:
          - path: /my-service
            pathType: Prefix
            backend: my-service
    (...)
```

## (중요) 보안그룹

- default는 0.0.0.0/0 전체 개방이기 때문에 `라이브시 반드시 보안그룹 설정` 필요
- 콘솔에서 직접 보안그룹을 설정시 신규 그룹을 생성하여 등록하는 방식이 좋음
- EKS 각 요소 간 공유되는 보안그룹이 많기 때문에, `기존 Managed 보안그룹에 보안 rule을 추가하는 방식은 다른 App.에 영향을 미치거나 삭제 위험성`이 있음

## (참고) LoadBalancer annotations [문서](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/guide/service/nlb/)

버전마다 annotations key-value가 꽤나 다르기 때문에 웹 상단에서 controller 버전 체크 필수