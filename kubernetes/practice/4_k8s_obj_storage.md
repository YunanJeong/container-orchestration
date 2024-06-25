# Storage 관리에 필요한 Object

## 간단 요약

- PV
  - 실제 스토리지(영구)를 정의하는 리소스
- PVC
  - `Pod가 어떤 스토리지가 필요한지(조건)` 정의하는 리소스
  - 신규 앱 배포시, `기존 배포된 PV 중 조건에 맞는 것을 찾아서 앱에 할당`
  - PVC 자체가 PV 자동생성기능을 갖춘 것은 아님!! Claim(요청)
  - 동적 프로비저닝의 경우 StorageClass를 참조
- 동적 프로비저닝
  - StorageClass와 Provisioner 기반으로 `PV를 자동생성`
  - 여러 헬름차트에서 사용되는 일반적 방법
- 정적 프로비저닝
  - PV 매니페스트를 관리자가 직접 작성하여 배포&할당
- StorageClass
  - 스토리지 유형을 정의하는 리소스
  - 동적 프로비저닝에 사용됨
- Provisioner
  - 동적 프로비저닝을 수행하는 주체
  - StorageClass를 기반으로 `PV를 자동생성하는 Pod(kube-system)`
    - StorageClass 매니페스트에서 Provisioner를 지정
  - 배포판 마다 다름. 기본내장되어있거나 추가설치 필요

## Persistent Volume (PV)

쿠버네티스에서는 컨테이너가 끊임없이 꺼졌다 켜졌다를 반복하는데, 중요한 데이터나 로그 등을 컨테이너 내부에 저장해놓을 수 없다. 따라서 `컨테이너와 별개로 관리되는 스토리지`가 필요하다. 이러한 스토리지 볼륨을 쿠버네티스에서는 PV라고 한다.

- 컨테이너 내부에 대용량 데이터 포함시 Scale-Out에 제약이 발생할 수 있으며 이는 컨테이너가 추구하는 Agility를 위반

PV 데이터의 실제 저장장소는 보통 쿠버네티스 노드의 로컬호스트(Local Storage)에 있다.클라우드 서비스에 따라서 해당 노드가 아닌 별도 스토리지(Network Storage)에 저장될 수 있다.

### PV Type

- 일반 볼륨에 타입이 있는 것처럼, PV에도 타입이 있음
- PV를 정의하는 `yaml의 spec 섹션 아래`에 기술됨 (하단 Example 참고)
- kubectl describe로 실행중인 PV의 타입 확인가능
- hostPath
  - 특정 노드의 파일 시스템 경로를 파드에 마운트
  - 테스트 환경이나 간단한 개발 환경
  - `hostPath의 경우 PV size를 지정해도 호스트 머신의 디스크가 충분하다면 용량을 초과해도 상관없다.` 단순 선언적 의미이고 용량제한 옵션은 별도 존재
- local
  - 특정 노드의 로컬 디스크를 사용하며, 고급 스케줄링과 내구성을 제공
  - 프로덕션 환경에서 로컬 스토리지를 사용할 때
- awsElasticBlockStore (AWS EBS)
  - AWS Elastic Block Store (EBS) 볼륨을 사용
  - AWS 환경에서 고성능과 내구성이 필요한 경우
- nfs (Network File System)
  - NFS 서버를 통해 네트워크 파일 시스템을 사용합니다.
  - 여러 노드에서 동시에 접근해야 하는 경우
- gcePersistentDisk (GCE PD)
  - Google Cloud Platform의 Persistent Disk를 사용
  - GCP 환경에서 고성능과 내구성이 필요한 경우
- azureDisk (Azure Disk)
  - Microsoft Azure의 Managed Disk를 사용
  - Azure 환경에서 고성능과 내구성이 필요한 경우

## Persistent Volume Claim (PVC)

PVC는 `앱을 배포하려는 사용자에게 스토리지의 물리적인 세부 사항을 숨기고, 단순히 필요한 리소스를 요청하는 인터페이스를 제공`하는 Object

- PVC는 `PV에 대한 요청`을 추상화 한 것이다. Claim 단어의 뉘앙스는 `청구하다`이다.

물리적인 스토리지 세부사항은 인프라 관리자, K8s 관리자, 매니지드 서비스 공급자가 처리한다.

사용자는 PVC를 통해 필요한 스토리지 용량 및 접근 모드를 설정하여 요청할 수 있다.

쿠버네티스 시스템은 이 요청을 충족하는 PV를 찾아 연결하거나 동적 프로비저닝으로 새로운 볼륨을 생성한다.

## 용례

DB, Data Lake류, Kafka, Elasticsearch 등을 쿠버네티스로 배포했을 시 로그데이터를 PV에 저장해놓는다. 이러면 배포된 앱의 설정을 변경하기 위해 껐다가 다시켜도 연속성이 보장된다.

PV가 필요한 앱들은 일반적으로 헬름 차트 배포판에서 PV를 쉽게 활용할 수 있도록 세팅되어있기 때문에 그것을 활용하면 된다.

## StorageClass(SC)

PV를 프로비저닝하고 관리하는 방식을 정의하는 템플릿 역할

사용자가 PVC를 생성시 원하는 StorageClass를 선택하면, K8s는 해당 StorageClass에 정의된 요구사항(용량, 성능, 스토리지 유형 등)에 맞는 PV를 자동으로 프로비저닝

## Provisioner

스토리지 볼륨을 자동으로 생성하고 관리(동적프로비저닝)하는 역할을 하는 쿠버네티스 컴포넌트

보통 클러스터 내 `kube-system의 Pod로 실행`된다. 배포판, 스토리지 유형에 따라 필요한 Provisioner가 다르며, 기본내장되어있거나 추가설치 필요

### 동적 프로비저닝

- 사용자가 PVC 생성시, 해당 PVC의 요구사항에 맞는 PV를 자동생성
- 이 과정은 수동으로 PV를 미리 생성하고 관리할 필요 없이, 필요에 따라 자동으로 스토리지 리소스를 할당하고 관리할 수 있게 해줌

### 스토리지 유형에 따른 관리

- 각 스토리지 유형에 맞는 Provisioner들이 있음
  - 로컬디스크: 배포판마다 다름. k3s는 local-path-provisioner.
  - NFS: 원격 스토리지 유형에 따라 다름
  - AWS EBS: kubernetes.io/aws-ebs
  - Google Cloud Persistent Disk: kubernetes.io/gce-pd
  - Azure Disk: kubernetes.io/azure-disk
- StorageClass에서는 이러한 백엔드 유형을 provisioner 필드를 통해 지정가능
- 유형에 맞는 Provisioner를 클러스터에 사전배포해둬야 함

### 효과: 자동화 및 효율성 증대

- Provisioner를 사용함으로써 스토리지 관리 자동화
- 사용자는 스토리지의 물리적인 세부사항을 신경 쓸 필요 없이 필요한 리소스를 쉽게 요청하고 사용가능
- 특히, 클라우드 기반 스토리지 관리에 효율적
- e.g.
  - PVC에서 30GB PV가 필요하다고 설정하고 배포하면,
  - 30GB짜리 AWS EBS가 자동생성되고 클러스터 내 PV 오브젝트와 동일시됨.
  - AWS EBS콘솔에서 직접 설정 필요없음.
  - PVC를 삭제하면 PV 오브젝트가 삭제됨과 동시에 EBS도 자동삭제

## Example

```yaml
##################################################################################
# 차트에서 자동생성되는 PV대신 별도 PV를 사용하고자할 때,
# 이 매니페스트로 pv와 pvc를 사전생성한다.
# 차트 values의 persistence.existingClaim섹션에서는, 사전생성된 pvc이름을 할당해주자. 

# e.g.) pv의 로컬저장경로 변경해서 사용하는 경우
##################################################################################

apiVersion: v1
kind: PersistentVolume
metadata:
  name: kafka-pv-0
  labels:
    name: kafka-pv-0    # PVC가 이 PV를 selector로 참조할 수 있도록 레이블 설정
spec:
  capacity:
    storage: 480Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data"       # PV 데이터가 실제 저장되는 로컬호스트의 경로

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kafka-pv-claim-0   # 헬름values의 existingClaim섹션에서 이 이름을 참조시켜 준다.
spec:
  accessModes:
    - ReadWriteOnce     # 사용할 pv 설정과 일치시켜 준다.
  resources:
    requests:
      storage: 480Gi    # 사용할 pv 설정과 일치시켜 준다.
  
  selector:
    matchLabels:
      name: kafka-pv-0  # pvc가 특정 pv를 참조하도록 설정

  storageClassName: ""
                        # 빈 문자열 => storageClass 미지정 (동적 프로비저닝 비활성화)
                        # 빈 값 or 섹션생략 => default storageClass 지정됨 (default provisioner에 의한 동적 프로비저닝 활성화)

```

- 커스텀 PVC, PV 적용시 Pod 배포가 실패하는 경우가 있다.
  - 매니페스트, 헬름차트 등에서 `mkdir로 필요한 경로를 자동생성하려다 권한문제로 실패`하기 때문
  - 다음과 같이 해결가능

```sh
# 777보다는 더 fit한 권한부여가 바람직
sudo chmod 777 {pv의 실제로컬경로}
```
