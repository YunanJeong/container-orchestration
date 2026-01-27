# kustomize

kustomize[커스터마이즈]는 쿠버네티스 오브젝트 설정을 템플릿(template) 방식이 아닌 패치(patch) 방식으로 관리하는 도구다. 원본 yaml을 수정하지 않고 환경별 차이점만 별도로 정의하여 최종 매니페스트를 생성한다.

## 주요 특징
- 2019년 kubectl v1.14부터 기본 내장되어 별도 설치 없이 사용 가능
- pure yaml: 별도의 템플릿 문법(go template 등) 없이 순수 yaml만 사용함
- overlay 구조: 공통 설정(base)과 환경별 설정(overlay)을 분리하여 관리함
- declarative: 선언적인 방식으로 리소스의 변경 사항을 기술함

## 핵심 구성 요소
- kustomization.yaml: kustomize의 설정 파일로 리소스 목록, 패치, 변수 등을 정의함
- base: 여러 환경에서 공통으로 사용하는 쿠버네티스 리소스 집합
- overlays: 특정 환경에 맞게 base를 수정하거나 추가하는 설정

## 디렉토리 구조 예시
원본이 되는 base와 환경별 변경 사항을 담은 overlays를 분리하여 관리한다.

```text
.
├── base/
│   ├── kustomization.yaml
│   └── kafka-cluster.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml
    │   └── patch-replicas.yaml
    └── prod/
        ├── kustomization.yaml
        └── patch-resources.yaml
```

## 주요 기능 및 수치
- 내장 도구: kubectl v1.14 버전부터 별도 설치 없이 `kubectl apply -k` 명령어로 사용 가능
- 생성기(generators): configmap과 secret을 파일로부터 자동으로 생성하며, 내용 변경 시 8자리 해시값을 이름에 추가하여 재배포를 강제함
- 변수 치환: commonlabels, commonannotations 기능을 통해 모든 리소스에 일괄적으로 메타데이터 주입 가능

## kustomize vs Helm
kustomize는 별도 문법 없이 순수 yaml 패치 방식으로 동작하여 학습 곡선이 낮고 가볍다. 반면 Helm은 go template 문법을 사용하여 복잡한 로직 구현과 패키지 버전 관리에 강점이 있으나 숙련도가 필요하다. 단순 환경 분리는 kustomize가 유리하고, 복잡한 배포 자동화는 Helm이 더 많이 선택된다.

### 7. Kafka 및 Operator 연동 (데이터 엔지니어 활용안)
- Helm: Strimzi 오퍼레이터 엔진 자체를 설치할 때 사용
- Kustomize: 오퍼레이터가 관리할 Kafka 클러스터의 환경별 사양(broker 개수, 리소스 제한)을 패치할 때 사용

### 8. 주요 명령어
- 최종 YAML 확인: kubectl kustomize <directory_path>
- 즉시 적용: kubectl apply -k <directory_path>
- 리소스 삭제: kubectl delete -k <directory_path>
