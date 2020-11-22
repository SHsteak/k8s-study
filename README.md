# 목표

쿠버네티스에서 [spring-petclinic-data-jdbc](https://github.com/spring-petclinic/spring-petclinic-data-jdbc)를 서비스

# 환경

- CentOS 8 * 4ea
- 쿠버네티스 v1.19.4
- docker 19.03.13
- docker-compose 1.27.4

# 순서

1. NFS 서버 설정
2. 변수 설정
3. kubernetes - pv 생성
4. kubernetes - pvc 생성
5. kubernetes - DB 실행
6. 어플리케이션과 도커이미지 빌드
7. kubernetes - 어플리케이션 실행
8. kubernetes - ingress 실행
9. kubernetes - 동작 확인
10. kubernetes - 삭제

# 사용법

## NFS 서버 설정

1. nfs-utils 설치

    ```bash
    sudo yum install nfs-utils -y

    systemctl enable --now nfs-server && systemctl enable --enable rpcbind
    ```

2. 데이터를 저장할 디렉토리 생성

    ```bash
    sudo mkdir -p /Data/mysql
    sudo chmod 777 -R /Data
    ```

3. NFS

    ```bash
    # 아래 IP는 수정이 필요할 수도 있습니다.
    /Data/mysql 192.168.*.*(rw,sync,no_root_squash)
    ```

4. 확인

    ```bash
    sudo yum install showmount -y

    sudo showmount -e localhost

    # 출력
    Export list for localhost:
    /Data/mysql 192.168.*.*
    ```

## 변수 설정

sh 스크립트로 최초 1회 변경 후에는 직접 파일을 찾아 변경해야 합니다..

1. sh 파일 권한 수정

    ```bash
    chmod 777 ./shctl.sh ./app/app-build.sh ./app/app-build-here.sh
    ```

2. 도커 이미지명:태그 설정

    `./app/app-build.sh`

    `./k8s/was/was-deployment.yaml`

    ```bash
    ./shctl.sh set imageName <이미지명>:<태그>

    # 예시
    ./shctl.sh set imageName choshsh/spring-petclinic-data-jdbc:latest
    ```

3. 쿠버네티스 ingress host 설정

    `./k8s/web/nginx-ingress.yaml`

    ```bash
    ./shctl.sh k set ingressDomain <도메인명>

    # /etc/hosts 파일에 등록
    sudo cat >> /etc/hosts <<EOF
    <ip>   <도메인명>
    <<EOF

    # 예시
    ./shctl.sh set ingressDomain www.choshsh.com

    sudo cat >> /etc/hosts <<EOF
    192.168.220.130   www.choshsh.com
    <<EOF
    ```

4. 쿠버네티스 퍼시스턴트 볼륨에 NFS 설정

    `./k8s/storage/mysql-pv.yaml`

    ```bash
    ./shctl.sh set pvNfs <ip> <nfs-dir-path>

    # 예시
    ./shctl.sh set pvNfs 192.168.220.130 /Data/mysql
    ```

## kubernetes - pv 생성

```bash
./shctl.sh k pv
```

## kubernetes - pvc 생성

```bash
./shctl.sh k pvc
```

## kubernetes - DB

```bash
./shctl.sh k db
```

## 어플리케이션과 도커이미지 빌드

```bash
./shctl.sh k build
```

최초 실행 시, gradle 도커이미지가 없다면 pull이 실행

최초 빌드 시 속도가 많이 느리지만,
2회부터는 `./app/.gradle-caches`를 gradle 이미지에 bind mount하여 속도 향상

jar 빌드 → 도커이미지 빌드 → 도커 push

## kubernetes - 어플리케이션 실행

- 실행

    ```bash
    ./shctl.sh k was
    ```

- scale in/out

    ```bash
    ./shctl.sh k was <Replicas 개수>

    # 예시
    ./shctl.sh k was scale 5
    ```

## kubernetes - ingress 실행

```bash
./shctl.sh k web
```

## kubernetes - 동작 확인

```bash
# 상태 확인
curl -Is <도메인명>:<ingress 서비스의 노드 포트>

# html 소스 확인
curl <도메인명>:<ingress 서비스의 노드 포트>
```

- 예시

    ```bash
    $ k get ingress minimal-ingress
    NAME              CLASS    HOSTS             ADDRESS   PORTS   AGE
    minimal-ingress   <none>   www.choshsh.com             80      4m48s

    $ k get svc ingress-nginx
    NAME            TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
    ingress-nginx   LoadBalancer   10.107.37.174   <pending>     80:30429/TCP,443:32491/TCP   5m12s

    # 상태 확인
    $ curl -Is www.choshsh.com:30429
    HTTP/1.1 200
    Server: openresty/1.15.8.2
    Date: Sun, 22 Nov 2020 21:18:47 GMT
    Content-Type: text/html;charset=UTF-8
    Content-Length: 3645
    Connection: keep-alive
    Vary: Accept-Encoding
    Content-Language: en

    # html 소스 확인
    $ curl www.choshsh.com:30429
    ```

## kubernetes - 삭제

- 전체 삭제

    ```bash
    ./shctl.sh k reset
    ```

- 선택 삭제

    ```bash
    # ingress 관련
    ./shctl.sh k web del

    # 어플리케이션 관련
    ./shctl.sh k was del

    # DB 관련
    ./shctl.sh k db del

    # 볼륨 관련
    ./shctl.sh k pvc del
    ./shctl.sh k pv del
    ```

# 참고한 사이트

쿠버네티스 ([https://kubernetes.io/ko/docs/home/](https://kubernetes.io/ko/docs/home/))

카카오테크 ([https://tech.kakao.com/2018/12/24/kubernetes-deploy/](https://tech.kakao.com/2018/12/24/kubernetes-deploy/))

조대협의 블로그 ([https://bcho.tistory.com/1255](https://bcho.tistory.com/1255))

네이버 클라우드 플랫폼 ([https://docs.ncloud.com/ko/nks/nks-1-4.html](https://docs.ncloud.com/ko/nks/nks-1-4.html))
