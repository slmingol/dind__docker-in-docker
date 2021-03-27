# Docker in Docker (DinD) Example

## Verify MTU set to 1420
```
$  docker build .
$  docker run -it --privileged --rm -d --name dind \
    $(docker image  ls | grep '<none>' | head -1 | awk '{print $3}') --mtu=1420


$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS           NAMES
700f961e78b6   68417a7d2516   "dockerd-entrypoint.…"   About a minute ago   Up About a minute   2375-2376/tcp   dind


$ docker exec -it dind \
    docker run --privileged -it --rm leodotcloud/swiss-army-knife:latest ip addr list

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
3: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN group default qlen 1000
    link/tunnel6 :: brd ::
5: eth0@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1420 qdisc noqueue state UP group default
    link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.18.0.2/16 brd 172.18.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```


## Running things interactively
```
$ docker run -it --privileged --rm --name dind \
    $(docker image  ls | grep '<none>' | head -1 | awk '{print $3}') sh

+ '[' 1 -eq 0 ]
+ '[' sh '!=' sh ]
+ '[' sh '=' dockerd ]
+ set -- docker-entrypoint.sh sh
+ exec docker-entrypoint.sh sh
/ # 
```

### From within container
```
/ # /usr/local/bin/dockerd-entrypoint.sh --mtu=1410
+ '[' 1 -eq 0 ]
+ '[' '-mtu=1410' '!=' '--mtu=1410' ]
+ id -u
+ uid=0
+ '[' 0 '=' 0 ]
+ dockerSocket=unix:///var/run/docker.sock
+ '[' -n /certs ]
+ _tls_generate_certs /certs
...
...
Getting CA Private Key
+ cp /certs/ca/cert.pem /certs/client/ca.pem
+ openssl verify -CAfile /certs/client/ca.pem /certs/client/cert.pem
/certs/client/cert.pem: OK
+ '[' -s /certs/server/ca.pem ]
+ '[' -s /certs/server/cert.pem ]
+ '[' -s /certs/server/key.pem ]
+ set -- dockerd '--host=unix:///var/run/docker.sock' '--host=tcp://0.0.0.0:2376' --tlsverify --tlscacert /certs/server/ca.pem --tlscert /certs/server/cert.pem --tlskey /certs/server/key.pem '--mtu=1410'
+ DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS=' -p 0.0.0.0:2376:2376/tcp'
+ '[' dockerd '=' dockerd ]
+ find /run /var/run -iname 'docker*.pid' -delete
+ id -u
+ uid=0
+ '[' 0 '!=' 0 ]
+ '[' -x /usr/local/bin/dind ]
+ set -- /usr/local/bin/dind dockerd '--host=unix:///var/run/docker.sock' '--host=tcp://0.0.0.0:2376' --tlsverify --tlscacert /certs/server/ca.pem --tlscert /certs/server/cert.pem --tlskey /certs/server/key.pem '--mtu=1410'
+ exec /usr/local/bin/dind dockerd '--host=unix:///var/run/docker.sock' '--host=tcp://0.0.0.0:2376' --tlsverify --tlscacert /certs/server/ca.pem --tlscert /certs/server/cert.pem --tlskey /certs/server/key.pem '--mtu=1410'
INFO[2021-03-27T02:18:52.065467100Z] Starting up
WARN[2021-03-27T02:18:52.068163700Z] could not change group /var/run/docker.sock to docker: group docker not found
INFO[2021-03-27T02:18:52.069810200Z] libcontainerd: started new containerd process  pid=66
INFO[2021-03-27T02:18:52.069940300Z] parsed scheme: "unix"                         module=grpc
INFO[2021-03-27T02:18:52.069979000Z] scheme "unix" not registered, fallback to default scheme  module=grpc
INFO[2021-03-27T02:18:52.070016300Z] ccResolverWrapper: sending update to cc: {[{unix:///var/run/docker/containerd/containerd.sock  <nil> 0 <nil>}]
```

**NOTE:** Above you can see the `--mtu=1410` passed into the invocation of `dockerd`.

### And to confirm within a nested docker container that its MTU is 1410
```
$ docker exec -it dind docker run --privileged -it --rm leodotcloud/swiss-army-knife:latest ip addr list
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
3: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN group default qlen 1000
    link/tunnel6 :: brd ::
7: eth0@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1410 qdisc noqueue state UP group default
    link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.18.0.2/16 brd 172.18.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```
