# plugins

## 쿠버네티스에서 추가 플러그인 처리 방법

### ConfigMap/Secret

- 모든 Node, Pod 간 공유 가능
- 1MB 제한으로 범용적 사용이 힘듦

### initContainer 또는 Volume 활용

#### 방법1: Pod 내 다운로드

- initContainer에서 저장소 등으로부터 Pull
  - 공식(온라인 환경)
  - 사설, 프록시(보안 및 오프라인 환경)
- initContainer와 본래 App. Container 간 Volume을 통해 파일 공유
- 단점: 초기화 느림

#### 방법2: 로컬파일을 Pod에 전달

- hostPath 타입 Volume
  - localhost와 Pod 간 디렉토리 공유
  - 단점: Node 간 공유 불가, 클러스터의 각 Node 마다 로컬환경에 플러그인 미리 탑재 필요
- emptyDir
  - ...

#### 방법3: persistentVolume

- network 타입: 공통 스토리지에서 플러그인 공유
- local 타입: Node 간 공유불가

#### 방법4: 플러그인 전용 image 빌드

- 플러그인 image를 만들고, initContainer로 실행 후 위 방법들처럼 Volume으로 App에 배포
- 단점: 차라리 아래 방법 처럼 App과 플러그인을 모두 포함하여 서비스 별 이미지를 각각 만드는 게 관리가 편할 수 있음

### 플러그인을 포함하여 새 이미지 만들기

- 동일버전, 동일 앱을 쓰더라도 프로젝트 및 서비스 별 전용 image가 필요함을 인정하고, App.과 플러그인을 모두 하나의 image로 빌드하기
- K8s 사용시,
  - `이미지 빌드가 자주 필요한 경우 배포도구로 Skaffold` 등을 써야 함
    - e.g. 코드작업이 필요한 Streams, 직접 만든 소스코드
  - `어차피 플러그인은 초기작업 외엔 자주 바뀌지 않을 것이므로 docker build 후 helm배포 하는 방식`으로 작업하면 된다.
    - e.g. 오픈소스 이미지에 내가 원하는 플러그인을 추가하는 경우 (Kafka Connector, DBeaver DB Driver)

### Sidecar (플러그인용도로 사용불가)

- Pod 내 본래 App. Container와 함께 실행되는 Container
- 설정파일 등을 관리할 때 사용됨
- sidecar는 본 App. Container보다 먼저 실행된다는 보장이 없음.
  - App. 실행 중에 플러그인 파일이 추가되어도 반영되는 경우는 잘 없으므로 플러그인 배포용도로 사용하기는 힘듦

### Static Pod? => initContainer

- 노드 간 공유되나, Pod 내부에서만 공유되나 여부도 중요
- 배포 편의성 고려 해야 함
- 오프라인 환경 고려 필요
- 보안 환경에서 사설&프록시 저장소를 이용가능하다고 가정해도, python, gem, File 등 여러 유형으로 저장소가 파편화되면 사용하기 힘듦. 사설 저장소 쓰더라도 git과 image 저장소 정도만 이용한다고 생각해야 함
