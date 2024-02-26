# etc-tools

## k9s

터미널에서 쿠버네티스를 모니터링&관리할 수 있는 GUI 제공

매우 편리하므로 꼭 설치하자.

- binary파일 하나만 설치하면 됨
- kubectl의 기능 대부분 가능하며 조작이 매우 쉬움
- 컨테이너 원격접속, Pod 임시 외부 포트 개방 등의 기능도 단축키로 간편하게 처리가능
- 클러스터의 전반적인 현재상태를 한 눈에 확인가능

### install

[Github 릴리즈 파일](https://github.com/derailed/k9s/releases)

```sh
# 커맨드로 최신 버전 설치
sudo apt install -y jq
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
curl -sL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz | sudo tar xfz - -C /usr/local/bin k9s
```

### How to use

- GUI 상단에 현재 사용가능한 단축키가 항상 보임

- `:{Object}`
  - 해당 항목만 조회
  - :pod
  - :service
  - :deploy
  - ...

- `s`: ssh remote connection
- `l`: log
- `d`: describe

### k9s logger

k9s로 Pod로그 조회시, 최근 것만 보이는 문제가 있다.
`~/.config/k9s/config.yml`에서 기본설정을 다음과 같이 변경한다.

```yaml
k9s:
  logger:
    tail: 500
    buffer: 5000
    sinceSeconds: -1
```

## kubectl krew

[Quick Start](https://krew.sigs.k8s.io/docs/user-guide/quickstart/)

```sh
kubctl ctx
kubctl ns
```

## fzf

`k ctx` 할 때 클러스터명을 직접 입력할 필요없이, 리스트 선택창으로 보여줌

- [fzf github](https://github.com/junegunn/fzf?tab=readme-ov-file#installation)

```sh
# ubuntu 설치
sudo apt install fzf
```

## kubectl fuzzy
