# EKS에서 앱 외부노출 방법 (AWS Load Balancer Controller)

## AWS Load Balancer Controller 사전 설치 필요

- AWS 서비스 중 하나인 Elastic LoadBalancer를 생성하기 위한 Controller
- `Controller 설치 후 클러스터 내 실제 Pod 형태로 확인`가능하며, 해당 Pod는 Elastic LoadBalancer 서비스에 접근가능한 IAM Role을 가져야 한다.
- 따라서 설치과정에 `IAM Role(Policy)설정`과 `Pod배포 과정`이 포함된다.
  - IAM Role을 생성하기 위해 awscli를 쓰는데, 이 때 awscli의 액세스키에는 IAMFullAccess 권한이 있어야 한다.
  - Pod 배포엔 eksctl, Helm 등 여러 방법이 사용될 수 있다. namespace kube-system에 한 번 설치후 업데이트전 까지 영구사용한다.
- [설치방법 문서](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html)를 따라하면 어렵지 않다.

### kube-controller-manager(in-tree) vs. AWS Load Balancer Controller

- `kube-controller-manager`
  - 클라우드 기능(AWS, GCP, Azure 등)을 제공하기 위해 업스트림 쿠버네티스에 포함된 도구라서, `in-tree` controller라고 칭해짐
- `AWS Load Balancer Controller`
  - AWS 특화기능 제공
  - in-tree controller 대신 이를 쓰는 것이 더 최신 권장사양
  - 쿠버네티스 입장에선 별도 툴이기 때문에 `out-of-tree` controller라고 칭해짐
  - helm,kubectl 등을 사용하여 클러스터 내 Pod로 배포되는 형태

## Service(Type: LoadBalancer)로 배포

- annotations에 두 줄 추가

```yaml
# Helm values.yaml 기준
service:
  type: LoadBalancer
  annotations: 
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"                # Network Load Balancer
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"  # default: internal(VPC)
    service.beta.kubernetes.io/load-balancer-source-ranges: "10.0.0.1/24, 198.168.0.1/24"  # NLB의 보안그룹 inbound를 cidr로 설정. 미설정시 0.0.0.0/0
```

## Ingress로 배포

두 가지 방법이 있음. 장단점이 다양. 용도에 따른 선택

- instance type이 default라서 좀 더 보편적으로 쓰이고, AWS 각 서비스와 호환성이 좋다고 함. 단, 배포된 서비스 많으면 클러스터 내부의 iptables 부하 이슈 등 가능성...
- ip type은 속도가 빠르고, 보안 이슈 있음

### 방법1 (target-type: instance)

- 아래 예시처럼 ingress의 annotation 최소설정 필요
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
    kubernetes.io/ingress.class: alb  # Application Load Balancer. "spec.ingressClassName: alb" 불가
    alb.ingress.kubernetes.io/scheme: internet-facing  # default: internal
    alb.ingress.kubernetes.io/target-type: instance    # default
    alb.ingress.kubernetes.io/inbound-cidrs: "10.0.0.1/24, 198.168.0.1/24" # ALB의 보안그룹 Inbound를 cidr로 설정. 미설정시 0.0.0.0/0
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
    kubernetes.io/ingress.class: alb  # Application Load Balancer. "spec.ingressClassName: alb" 불가
    alb.ingress.kubernetes.io/scheme: internet-facing    # default: internal
    alb.ingress.kubernetes.io/target-type: ip            
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

## (중요) 라이브용 로드밸런서 개별 보안그룹 설정 필수

- default: 전체 개방