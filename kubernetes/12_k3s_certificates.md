# 쿠버네티스 인증서 관련

- 클러스터 컴포넌트 간 통신시 인증서가 필요
- 클러스터 최초의 k3s server 배포시 인증서가 자동생성됨
- 만료기한 10년짜리(Root CA)와 1년짜리(leaf)가 있음
- 클러스터 직접 통신에 사용되는건 leaf이고, Root CA 인증서는 leaf 인증서 생성시에만 사용됨
- 1년짜리 leaf 인증서 만료시 쿠버네티스 Pod앱은 유지되나, 클러스터 및 컨테이너 관리 기능 동작 중지
- leaf 인증서는 만료우회 & 쉬운 갱신 방법이 다양하게 있으나, 무슨 수를 써도 Root CA의 만료기한을 넘길 수 없음
- Root CA 갱신은 운영자의 인증서 수동 생성 및 교체가 필요하며, 클러스터 서비스 중단이 발생. server 뿐아니라 agent(worker노드)에서도 작업 필수
- `위 구조는 K3s와 업스트림 쿠버네티스 모두 동일`
- 후술할 인증서 갱신 및 관리방법은 K3s 기준으로 서술

## 해결방법

- 다양한 방법이 있으나, 가장 보편적인 방법을 기술한다
- Leaf(1년): `기한 90일 미만시 k3s server를 restart 해주면 1년 갱신`됨 => 크론탭 자동화 가능

```sh
# k3s server 재시작
sudo systemctl restart k3s.service

# 완전히 만료된 상태라면 k3s-server 재시작 후 각각 워커(k3s-agent)도 재시작 필요
sudo systemctl restart k3s-agent.service

# 90일 이상일 때 갱신방법(rotate 서브커맨드 실행 후 재시작)
sudo k3s certificate rotate
sudo systemctl restart k3s.service
```

- Root CA(10년)
  - 1순위: `클러스터 신규 구축` 후 마이그레이션
  - 2순위: 인증서 수동생성하여 수동교체
  - 기타: 간혹 IaC 도구로 자동화한 사례가 있긴함

## 인증서 기한 확인하기(k3s server가 있는 곳에서 체크한다)

```sh
# 인증서 확인(버전에 따라 미지원)
sudo k3s certificate check

# 인증서 확인(버전에 따라 미지원)
sudo k3s certificate --output table

# 위 명령어 불가시 스크립트 사용
sudo ./check-certs.sh
```

```sh
#!/usr/bin/env bash
# check-certs.sh
# k3s TLS 인증서(파일 시스템 및 Secret) 만료일 및 남은 일수 조회 스크립트
# Usage:
#   sudo ./check-certs.sh [mode]
# Modes:
#   all   - CA 인증서 + leaf 인증서 모두 조회 (기본)
#   ca    - CA 인증서만 조회
#   leaf  - leaf 인증서(Secret)만 조회

set -euo pipefail

mode="${1:-all}"
now_ts=$(date +%s)

# 파일 시스템 내 CA 인증서 경로
TLS_DIR="/var/lib/rancher/k3s/server/tls"

# 임시 디렉터리
TMP_DIR="$(mktemp -d)"

# CA 인증서 조회 함수 (filesystem)
collect_ca() {
  find "$TLS_DIR" "$TLS_DIR/etcd" 2>/dev/null -type f -name '*-ca.crt'
}

# leaf 인증서 조회 함수 (Secret)
collect_leaf() {
  sudo k3s kubectl -n kube-system get secret \
    -o jsonpath='{.items[?(@.type=="kubernetes.io/tls")].metadata.name}'
}

# 헤더 출력
printf '%-60s %-25s %10s\n' "SOURCE" "EXPIRES AT" "DAYS LEFT"
printf -- '%.0s-' {1..100}
printf '\n'

# 만료일 및 남은 일수 계산/출력 함수
print_cert() {
  local label="$1" crt_file="$2"
  local not_after exp_ts days_left
  not_after=$(openssl x509 -in "$crt_file" -noout -enddate | cut -d= -f2)
  exp_ts=$(date -d "$not_after" +%s)
  days_left=$(( (exp_ts - now_ts) / 86400 ))
  printf '%-60s %-25s %10d\n' "$label" "$not_after" "$days_left"
}

case "$mode" in
  all|ca)
    # CA 인증서 출력
    for caf in $(collect_ca); do
      print_cert "FILE: $caf" "$caf"
    done
    ;;
esac

case "$mode" in
  all|leaf)
    # leaf 인증서(Secret) 출력
    for name in $(collect_leaf); do
      crt_file="$TMP_DIR/${name}.crt"
      sudo k3s kubectl -n kube-system get secret "$name" \
        -o jsonpath='{.data.tls\.crt}' | base64 -d > "$crt_file"
      print_cert "SECRET: $name" "$crt_file"
    done
    ;;
esac

if [[ "$mode" != "all" && "$mode" != "ca" && "$mode" != "leaf" ]]; then
  echo "Usage: sudo $0 [all|ca|leaf]"
  exit 1
fi

# 임시 파일 정리
rm -rf "$TMP_DIR"

```
