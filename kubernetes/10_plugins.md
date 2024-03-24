# 쿠버네티스에서 추가 플러그인 처리 방법

- initContainer
  - 온라인 저장소 다운로드
  - 오프라인 환경의 경우: 사설 저장소, 프록시 저장소 다운로드
  - extraVolume (hostPath, emptyDir)
  - network PVC
  - 플러그인만 별도 image로 등록 후 initContainer와 Volume으로 연계 

- `플러그인+본 앱을 하나의 image로 빌드`

sidecar는 본 App. Container보다 먼저 실행된다는 보장이 없음. App. 실행 중에 라이브러리 파일이 추가되어도 반영되는 경우는 잘 없으므로 보통은 initContainer 쓰면 될듯

- 노드 간 공유되나, Pod 내부에서만 공유되나 여부도 중요
- 배포 편의성 고려 해야 함
- 오프라인 환경 고려 필요
- 보안 환경에서 사설, 프록시 저장소를 쓴다고 하더라도 python, gem, 파일 등 저장소가 너무 파편화되면 사용하기 힘듦. 사설 저장소 쓰더라도 git과 image 저장소만 있다고 생각해야 함.
