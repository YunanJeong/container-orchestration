# Docker network_mode

## bridge (default)
- container 생성시 랜덤 사설IP가 할당된다.
- container->host로 데이터 전송시 localhost가 아닌 `host.docker.internal`(container에서 바라보는 host의 IP)를 IP 주소로 이용해야 한다.

## host
- container 안의 프로세스는 host의 프로세스로 취급된다. 통신시 localhost를 쓰면된다.

# bridge 모드에서 IP 범위 관련 이슈
## 개요
- container IP는 172.x.x.x로 할당된다.(default)
- 아래 이슈발생시 container IP 할당 범위 및 docker bridge IP를 조정 필요
## 문제1
- host가 사설망(172.x.x.x)에 있는 경우, container IP와 대역(subnet, cidr)이 겹칠 가능성 있음
- host의 라우팅 테이블에서는 기존 설정이 무시되고, Docker로 인해 설정된 IP가 우선 적용
- 이에 따라 container, host 간 통신이 불가능

## 문제2
- host가 보안 사설망에 있는 경우, container끼리 혹은 container, host 간 통신에도 특정 IP,Port에 대한 보안인가가 필요할 수 있다.

## 해결방법: 도커 브릿지 및 컨테이너의 자동할당 IP 범위를 조정한다

0. CIDR(Subnet) 사전지식 필요
- IPv4 주소를 쪼개어 사용하는 방법에 있어서 Subnet과 CIDR은 사실상 같은 개념이다.
- CIDR이 더 넓은 대역, 더 디테일한 네트워크 분할을 사용하는 최신 개념이다.

1. `/etc/docker/daemon.json` 파일을 다음과 같이 생성
    ```
    {
        "bip": "10.10.0.1/24",
        "default-address-pools":[
            {"base": "10.10.0.1/16", "size": 24}
        ]
    }
    ```
    - bip (Default Bridge IP)
        - 정확히는 IP라기보다 host와 분리되어 운용될 도커전용 Subnet(CIDR Network)을 정의하는 값이다.
        - `docker run` 했을 때 디폴트로 선택되는 network
        - `ifconfig` 했을 때 docker0
        - `docker image ls` 했을 때 `bridge` network 에 해당
        - bip의 Maskbits(CIDR blocks)는 24를 주로 사용한다. (default)

    - default-address-pools:
        - bridge network 외에 다른 `도커 network가 자동생성될 때 배정되는 IP 범위`를 정한다.
        - 대표적으로 `docker compose up` 했을 때 자동생성되는 `ubuntu_default` network가 이 설정을 따른다. default-address-pools에서 network대역이 부족할 경우, `ubuntu_default`생성에 실패한다.
        - base:
            - CIDR 형식 표기(IP/MaskBits)
            - bridge network 외에 `다른 도커 network들이 사용할 전체 IP 범위`
            - **Docker Container는 base 대역에 그대로 할당되지 않는다. base가 다시 개별 도커 network으로 분리된 후 할당된다.** APP,서비스,시나리오에 따라 여러 Container 그룹들이 여러 Subnet으로 격리되어야 할 때도 있기 때문이다.
            - bip 설정이 따로 없으면, 가용 network 범위 중 첫번째 IP주소 범위를 bip로 쓴다.

        - size:
            - MaskBits만 표기 (base의 MaskBits보다 큰 수 입력 필요)
            - bip 설정의 Maskbits와 값이 같아야 한다.
            - `Host Address Range의 개수(1개의 network에서 몇 개의 Container IP address가 할당될 수 있는지)`를 나타낸다.
            - **size값에 따라 base가 몇개의 도커 network로 나눠져야하는지 확정**


2. docker 재시작 `sudo systemctl restart docker`
    - /etc/docker/daemon.json의 syntax가 맞아도, 가끔 docker 재실행이 비정상처리되는데 다음과 같이 한다.
    - `sudo systemctl stop docker.service docker.socket` 후 잠깐 기다린다.
    - `sudo systemctl start docker`

3. container 재실행 후 `ifconfig` or `ipconfig`로 IP 확인
    - host는 각 도커 network의 브릿지와 연결되므로, 다음 항목에 표기된 IP는 해당 network의 첫번째 주소(Gateway)이기도 하다. (참고: 여기서 '브릿지'란, 디폴트 도커 network의 이름인 'bridge'말고 일반적인 네트워크 용어로 사용한 것이니 헷갈리지 말자)
    - `docker0`
        - 디폴트 도커 network (bridge network) 쪽 인터페이스
    - `br-xxxxx`
        - 자동생성된 도커network 쪽 인터페이스
        - br은 네트워크 용어 bridge의 약자
    - `veth..xxx..`
        - virtual ethernet
        - Container 개수만큼 veth가 생성되었는지만 확인하면 된다.
        - bridge모드에선 각 Container가 개별 host로 취급되니 Container 당 하나씩 MAC주소가 필요하다. 이를 도커가 알아서 처리해주는 부분이라고 생각하자. veth는 블로그에서 도커 네트워크 설명시 자주 등장하는데, 이번 이슈는 IP 관련이라 별 신경 쓸 필요는 없다.

4. `sudo docker network inspect bridge`로 bridge network 정보 확인 가능

5. `sudo docker network insepct ubuntu_default`
    - `docker compose up`했을 때 `docker-compose.yml`에 network 설정이 없으면, `ubuntu_default` network가 위 설정에 따라 자동생성되고, 컨테이너에 할당된다. 해당 Subnet(cidr network)의 ID와 Gateway를 확인할 수 있다.

---
6. 예시 설명
```
{
    "bip": "192.168.0.1/24",
    "default-address-pools":[
        {"base": "10.10.0.1/16", "size": 24}
    ]
}
```
- 앞서 언급했듯, Container는 base 영역(도커 network 전체 범위)에 직접 할당되는 것이 아니라, base가 개별 도커 network로 쪼개진 후 그 영역에 할당된다.
- *base의 MaskBits*는 16이고, *size(개별 도커 network의 Maskbits)* 는 24이므로 base에서 network 분리용도로 8bits(base의 뒤에서부터 9~16번째 bit)를 사용하게 된다. 즉, **10.10.[0-255].1/24 꼴로 총 256개의 도커 network**를 만들 수 있다.

- 각 network안에서 다음 IP를 제외하고 총 253개의 Container가 실행될 수 있다.
    - SubnetID(CIDR network ID)(10.10.X.0)
    - Gateway(10.10.X.1)
    - broadcast(10.10.X.255)
- 위 예시에서 `docker compose`로 처음 실행된 Container는 다음과 같은 자동생성 network에 소속된다.
    ```
    - Name: ubuntu_default
    - Subnet ID(CIDR network): 10.10.0.0
    - netMask(CIDR blocks): 255.255.255.0 (/24)
    - Gateway: 10.10.0.1
    ```
- 위 예시에서 만약 bip 설정이 별도로 없었다면, 10.10.0.1/24가 bridge network, 즉, bip로 사용된다. 가용 network(10.10.[0-255].1/24) 중 첫번째를 bridge network가 점유하므로, 가용 network 수가 1개 줄어든 것이다. 보통은 신경쓸 필요 없지만, 보안 사설망 등에서 네트워크 대역이 부족할 때 유의해야할 이슈다. 위 예시에서 bip를 없앤 채로 진행시, `docker compose`로 처음 실행된 Container는 다음과 같은 자동생성 network에 소속된다.
    ```
    - Name: ubuntu_default
    - Subnet ID(CIDR network): 10.10.1.0
    - netMask(CIDR blocks): 255.255.255.0 (/24)
    - Gateway: 10.10.1.1
    ```
- 본 예시는 bip와 CIDR이 다른 Class이다. 내부적으로 포트포워딩되므로 기능상 문제는 없다. 그러나 network 가용범위가 좁지 않다면, 관례적으로 같은 Class를 사용해준다.(10.x.x.x, 172.x.x.x, 192.x.x.x 맞춰서 쓰라는 말)