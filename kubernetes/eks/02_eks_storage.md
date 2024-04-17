# EKS에서 EBS를 PV로 쓰기

## AWS CSI Driver(ebs.csi.aws.com) 사전설치 필요

- PVC와 StorageClass로 PV를 자동생성하기 위해선, K3s의 local-path-provisioner처럼 eks용 provisioner가 필요하다.
- AWS CSI Driver가 eks의 provisioner이며, EBS 자동생성 기능까지 포함한다.
- `Driver 설치 후 클러스터 내 실제 Pod 형태로 확인`가능하며, 해당 Pod는 EBS 볼륨을 자동생성하기 위한 IAM Role을 가져야 한다.
- 따라서 설치과정에 `IAM Role(Policy)설정`과 `Pod배포 과정`이 포함된다.

[공식문서 설치방법](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
[공식github (Helm지원): aws-ebs-csi-driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
[설치방법 블로그](https://developc.tistory.com/entry/Amazon-EBS-CSI-driver)

## EKS용 provisioner 두 종류 비교

ebs.csi.aws.com vs. kubernetes.io/aws-ebs

### ebs.csi.aws.com

- `ebs.csi.aws.com가 최신사양이고, AWS CSI Driver`라고 칭해진다.
- eks 배포시 미포함이라 개별 설치 필요
- 설치 후 Pod 형태로 클러스터 내 조회가능
- ebs.csi.aws.com는 [공식github](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)에서 헬름 차트를 지원한다. 하지만 eksctl로 설치하는게 더 쉬워보이긴 한다.

```sh
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver -n kube-system -f values.yaml  # value 별도 설정 필요
```

### kubernetes.io/aws-ebs (사실상 Deprecated)

- 업스트림 쿠버네티스에 포함된 것으로, 배포판인 eks에도 기본 내장되어 있다.
  - 업스트림 쿠버네티스에선 계속 배포하지만, EKS에선 사실상 deprecated 취급
  - `eks 1.23버전 부터는 ebs.csi.aws.com(Amazon EBS CSI driver)가 강제`되므로 비권장
  - storageClass의 provisioner 참조가 kubernetes.io/aws-ebs로 되어 있어도 무시하고 ebs.csi.aws.com를 통해 PV 프로비저닝을 시도한다.
- 이 provisioner는 Pod 형태로는 보이지 않는다.
