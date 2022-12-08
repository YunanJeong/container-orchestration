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
1. `/etc/docker/daemon.json` 파일을 다음과 같이 생성
    - `/etc/docker/daemon.json`의 설정 방법은 여기서는 간단히 언급하고, 이 문서 아래에 더욱 자세히 기술한다.
```
{
    "bip": "10.10.0.1/24",
    "default-address-pools":[
        {"base": "10.10.0.1/16", "size": 24}
    ]
}
```
- bip:
    - bridge IP (ifconfig 했을 때 docker0)
    - bip는 docker가 점유하는 전체 Subnet과 host를 이어주는 Gateway 주소이다.
        - Container IP 할당범위을 의미하지는 않는다.
        - Container IP 할당범위를 지정하려면 default-address-pools 설정 필요
    - bip의 Maskbits는 24를 주로 사용한다. (default)
        - 남은 8bit로 다시 세부 Subnet을 구성하겠다는 의미이다.
        - default-address-pools 설정시, 일반적인 CIDR 블록 해석과 달리 맨뒷자리 8bit를 사용하는 것이 아닐 수 있다. 중간의 8bit를 사용할 수도 있다. (하단 설명 계속 참고)

- default-address-pools:
    - base:
        - CIDR표기(IP/MaskBits)
        - `host와 분리되어 docker 전체에서 점유할 IP 범위(docker 최상위 Subnet)`를 나타낸다.
        - bip 설정이 따로 없으면, Subnet 범위 중 첫번째 IP가 bip(최상위 GateWay)로 할당된다.
    - size:
        - MaskBits만 표기 (base의 MaskBits보다 큰 수 입력 필요)
        - bip 설정의 Maskbits와 값이 같아야 한다.
        - `Host Address Range(1개의 하위 Subnet에서 몇 개의 Container IP address가 할당될 수 있는지)`를 나타낸다.


2. docker 재시작 `sudo systemctl restart docker`
    - /etc/docker/daemon.json의 syntax가 맞아도, 가끔 docker 재실행이 비정상처리되는데 다음과 같이 한다.
    - `sudo systemctl stop docker.service docker.socket` 후 잠깐 기다린다.
    - `sudo systemctl start docker`

3. container 재실행 후 `ifconfig`로 변경된 IP로 할당되었는지 확인
    - docker0: bridge IP
    - br-xxxxx: 하위 subnet(cidr network)의 Gateway

4. `sudo docker network inspect bridge`로도 bridge ip를 확인할 수 있다.

5. `sudo docker network insepct ubuntu_default`
    - 별도로 network 모듈을 만들지 않았다면 ubuntu_default가 위 설정에 따라 자동생성되고, 컨테이너에 할당된다. 해당 하위 하위 subnet(cidr network)의 ID와 Gateway를 확인할 수 있다.

---
# `/etc/docker/daemon.json`의 설정 방법
## 개요
- Subnet(CIDR) 사전지식 필요
- IPv4 주소를 쪼개어 사용하는 방법에 있어서 Subnet과 CIDR은 사실상 같은 개념이다.
- CIDR이 더 넓은 대역, 더 디테일한 네트워크 분할을 사용하는 최신 개념이다.

## default-address-pools 설명
- **Docker Container는 base에서 설정된 최상위 Subnet에 그대로 할당되지 않는다. 최상위 Subnet이 다시 한번 세부 Subnet으로 분리된 후 할당된다.**
- APP,서비스,시나리오에 따라 여러 Container 그룹들이 서로 다른 Subnet으로 격리되어야 할 수 있기 때문이다.
- **size값에 따라 최상위 Subnet이 몇개의 세부 Subnet으로 쪼개져야하는지 확정**된다.

## 예시
```
{
    "bip": "192.168.0.1/24",
    "default-address-pools":[
        {"base": "10.10.0.1/16", "size": 24}
    ]
}
```
- *base(최상위 Subnet)의 MaskBits*는 16이고, *size(하위 Subnet의 Maskbits)* 는 24이므로 Subnet 분리용도로 8bits(뒤에서부터 9~16번째 bit)를 사용하게된다. 즉, **10.10.[0-255].1/24 꼴로 총 256개의 하위 Subnet**이 활용될 수 있다.
- 각 하위 Subnet안에서는 SubnetID(CIDR network ID)(10.10.x.0), Gateway(10.10.x.1), broadcast(10.10.x.255) 용 IP를 제외하면 253개의 Container가 실행될 수 있다.
- 위 설정에서 처음 실행된 Container는 다음과 같은 자동생성 network에 소속된다.
    ```
    - Name: ubuntu_default
    - Subnet ID(CIDR network): 10.10.0.0
    - netMask(CIDR blocks): 255.255.255.0 (/24)
    - Gateway: 10.10.0.1
    ```
- 만약 bip 설정이 별도로 없을 경우, 10.10.0.1이 최상위 Subnet의 Gateway, 즉, bridge IP로 사용된다. 이 때는 사용할 수 있는 하위 Subnet 중 첫번째 subnet을 bridge가 가져간게 되므로, 사용가능한 하위 Subnet 개수가 1개 줄어든 것이다. 처음 실행된 Container는 다음과 같은 자동생성 network(ubuntu_default)에 소속된다.
    ```
    - Name: ubuntu_default
    - Subnet ID(CIDR network): 10.10.1.0
    - netMask(CIDR blocks): 255.255.255.0 (/24)
    - Gateway: 10.10.1.1
    ```
- 본 예시는 bip와 CIDR이 다른 Class이다. 내부적으로 포트포워딩되므로 기능상 문제는 없다. 그러나 Subnet 가용범위가 좁지 않다면, 관례적으로 같은 Class를 사용해준다.(10.x.x.x, 172.x.x.x, 192.x.x.x 맞춰서 쓰라는 말)