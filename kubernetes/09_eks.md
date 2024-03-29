# EKS에서 앱 외부노출 방법 (AWS Load Balancer Controller)

## Service(Type: LoadBalancer)로 배포

- annotations에 두 줄 추가

```yaml
# Helm values.yaml 기준
service:
  type: LoadBalancer
  annotations: 
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"                # Network Load Balancer
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"  # default: internal(VPC)
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