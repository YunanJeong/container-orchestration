#!/bin/bash

# K3s Leaf 인증서(1년)을 자동 갱신하기 위한 크론탭을 "등록해주는" 스크립트

# k3s-server: 매월 1일 03:17에 rotate + restart
SERVER_CMD="17 3 1 * * $(command -v k3s) certificate rotate && $(command -v systemctl) restart k3s"

# k3s-agent: 매월 1일 03:27에 restart # 반드시 server작업 후 실행
AGENT_CMD="27 3 1 * * $(command -v systemctl) restart k3s-agent"

# 여기가 k3s-server 노드인지, k3s-agent 노드인지 판단
if systemctl is-active --quiet k3s; then
  CMD="$SERVER_CMD"
elif systemctl is-active --quiet k3s-agent; then
  CMD="$AGENT_CMD"
fi

# 크론탭에 적용 (기존 내용에 새 커맨드 추가 후 반영)
CRON_CUR=$(sudo crontab -l 2>/dev/null || true)
COMMENT="# K3s 인증서 만료 방지(매월 1일 재실행)"
CRON_NEW="$(printf "%s\n\n%s\n%s"  "$CRON_CUR" "$COMMENT" "$CMD")"
echo "$CRON_NEW" | sudo crontab -

# 확인
echo "sudo crontab -l >>>"
sudo crontab -l