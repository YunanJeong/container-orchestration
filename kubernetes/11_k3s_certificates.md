# 쿠버네티스 인증서 관련

- 클러스터 컴포넌트 간 통신시 인증서가 필요
- 클러스터 최초의 k3s server 배포시 인증서가 자동생성됨
- 만료기한 10년짜리(Root CA)와 1년짜리(leaf)가 있음
- 클러스터 직접 통신에 사용되는건 leaf이고, Root CA 인증서는 leaf 인증서 생성시에만 사용됨
- 1년짜리 leaf 인증서 만료시 쿠버네티스 Pod앱은 유지되나, 클러스터 및 컨테이너 관리 기능 동작 중지
- leaf 인증서는 만료우회 & 쉬운 갱신 방법이 다양하게 있으나, 무슨 수를 써도 Root CA의 만료기한을 넘길 수 없음
- Root CA 갱신은 운영자의 인증서 수동 생성 및 교체가 필요하며, 클러스터 서비스 중단이 발생. server 뿐아니라 agent(worker노드)에서도 작업 필수
- `위 구조는 K3s와 업스트림 쿠버네티스 모두 동일`하며, 후술할 인증서 갱신 및 관리방법은 K3s 기준으로 서술
- 참고: EKS 등 클라우드서비스에선 인증서가 자동관리되므로 고려할 필요 없음

## 해결방법

- 다양한 방법이 있으나, 가장 보편적인 방법을 기술한다

### Leaf(1년)

- `k3s-server에서 갱신 명령어 적용 후, 모든 노드(k3s,k3s-agent 서비스) 재시작`

```sh
# Leaf 인증서(1년짜리 갱신방법)

# k3s-server에서 인증서 갱신 후 서비스 재시작 
sudo k3s certificate rotate
sudo systemctl restart k3s.service

# 이후, 각 워커노드의 k3s-agent도 재시작 (순서 지킬 것)
sudo systemctl restart k3s-agent.service
```

- 기한 120일(구버전 90일) 미만일 경우, 명시적 갱신 명령어 없이도, 서비스 Restart시 자동갱신됨
- 갱신과정에서 기존 실행중인 Pod에는 영향없음
- K3s-server에서 갱신 작업 후,
  - server에서 갱신된 인증서를 agent가 다시 로드하지 않으면, 이후 재연결/재검증 과정에서 인증 불일치 문제가 발생할 수 있음
  - 따라서 겉보기엔 Pod가 잘 돌아가더라도, 향후 안정성을 위해 **agent도 반드시 재시작** 권장
- 자동화
  - 모든 서버에 직접 접속해 크론탭을 등록하는 것이 가장 무난함
  - 이 외에도 IaC/원격SSH/DaemonSet(hostPath) 등이 널리 쓰이지만 네트워크,보안,인프라 환경에 따른 권한 필요

```sh
#!/bin/bash

# K3s Leaf 인증서(1년)을 자동 갱신하기 위한 크론탭을 "등록해주는" 스크립트

# k3s-server: 매월 1일 03:15에 rotate + restart  # 갱신된 kubeconfig 파일권한 수정(편의상 넣었으나, 별도 관리하는게 원칙상 좋음)
SERVER_CMD="15 3 1 * * $(command -v k3s) certificate rotate && $(command -v systemctl) restart k3s  &&  $(command -v chmod) 644 /etc/rancher/k3s/k3s.yaml"

# k3s-agent: 매월 1일 03:25에 restart            # k3s-server 갱신 완료 후 k3s-agent 작업이 수행되어야 함
AGENT_CMD="25 3 1 * * $(command -v systemctl) restart k3s-agent"

# 여기가 k3s-server 노드인지, k3s-agent 노드인지 판단
if systemctl is-active --quiet k3s; then
  COMMENT="# K3s 인증서 만료 방지(매월 1일 재실행) # 갱신된 kubeconfig 파일권한 수정(편의상 넣었으나, 별도 관리하는게 원칙상 좋음)"
  CMD="$SERVER_CMD"
elif systemctl is-active --quiet k3s-agent; then
  COMMENT="# K3s 인증서 만료 방지(매월 1일 재실행) # k3s-server 갱신 완료 후 k3s-agent 작업이 수행되어야 함"
  CMD="$AGENT_CMD"
fi

# 크론탭에 적용 (기존 내용에 새 커맨드 추가 후 반영)
CRON_CUR=$(sudo crontab -l 2>/dev/null || true)
CRON_NEW="$(printf "%s\n\n%s\n%s"  "$CRON_CUR" "$COMMENT" "$CMD")"
echo "$CRON_NEW" | sudo crontab -

# 확인
echo "sudo crontab -l >>>"
sudo crontab -l
```

### Root CA(10년)

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
