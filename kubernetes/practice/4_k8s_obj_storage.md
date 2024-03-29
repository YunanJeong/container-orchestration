# Storage 관리에 필요한 Object

## Persistent Volume (PV)

쿠버네티스에서는 컨테이너가 끊임없이 꺼졌다 켜졌다를 반복하는데, 중요한 데이터나 로그 등을 컨테이너 내부에 저장해놓을 수 없다. 따라서 `컨테이너와 별개로 관리되는 스토리지`가 필요하다. 이러한 스토리지 볼륨을 쿠버네티스에서는 PV라고 한다.

- 컨테이너 내부에 대용량 데이터 포함시 Scale-Out에 제약이 발생할 수 있으며 이는 컨테이너가 추구하는 Agility를 위반

PV 데이터의 실제 저장장소는 보통 쿠버네티스 노드의 로컬호스트(Local Storage)에 있다.클라우드 서비스에 따라서 해당 노드가 아닌 별도 스토리지(Network Storage)에 저장될 수 있다.

## Persistent Volume Claim (PVC)

PVC는 `앱을 배포하려는 사용자에게 스토리지의 물리적인 세부 사항을 숨기고, 단순히 필요한 리소스를 요청하는 인터페이스를 제공`하는 Object

- PVC는 `PV에 대한 요청`을 추상화 한 것이다. Claim 단어의 뉘앙스는 `청구하다`이다.

물리적인 스토리지 세부사항은 인프라 관리자, K8s 관리자, 매니지드 서비스 공급자가 처리한다.

사용자는 PVC를 통해 필요한 스토리지 용량 및 접근 모드를 설정하여 요청할 수 있다.

쿠버네티스 시스템은 이 요청을 충족하는 PV를 찾아 연결하거나 동적 프로비저닝으로 새로운 볼륨을 생성한다.

## 용례

DB, Data Lake류, Kafka, Elasticsearch 등을 쿠버네티스로 배포했을 시 로그데이터를 PV에 저장해놓는다. 이러면 배포된 앱의 설정을 변경하기 위해 껐다가 다시켜도 연속성이 보장된다.

PV가 필요한 앱들은 일반적으로 헬름 차트 배포판에서 PV를 쉽게 활용할 수 있도록 세팅되어있기 때문에 그것을 활용하면 된다.
