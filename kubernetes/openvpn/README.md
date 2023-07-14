[[Back to Index Page](../README.md)]

# OpenVPN on Kubernetes

OpenVPN server in a Docker container running on Kubernetes.

## The Goal

1. We want to be able to access Kubernetes homelab subnet `10.11.1.0/24` from the Internet using a VPN connection on an Android device. This would allow us to access internally hosted services like:
    * https://grafana.apps.hl.test
    * https://prometheus.apps.hl.test
2. We want to route all traffic through the VPN server (push default gateway).

# Configuration

1. [Docker Image](#docker-image)
2. [Create Kubernetes Namespace](#create-kubernetes-namespace)
3. [Generate OpenVPN Configuration Files and Certificates](#generate-openvpn-configuration-files-and-certificates)
4. [Deploy OpenVPN on Kubernetes](#deploy-openvpn-on-kubernetes)
5. [Configure Mikrotik Router](#configure-mikrotik-router)
6. [Test VPN Access from Android Client](#test-vpn-access-from-android-client)
7. [Configuration Variables](#configuration-variables)

## Docker Image

We use [lisenet/openvpn:latest](https://hub.docker.com/r/lisenet/openvpn) docker image. This image was built using Dockerfile from [lisenet/docker-openvpn](https://github.com/lisenet/docker-openvpn/blob/master/Dockerfile).

## Create Kubernetes Namespace

```bash
kubectl create ns openvpn
```

## Generate OpenVPN Configuration Files and Certificates

Set environment variables to be used to generate OpenVPN config. See [Configuration Variables](#configuration-variables) and their defaults if undefined.

```bash
export VPN_HOSTNAME="vpn.example.com"
export DNS_SERVER="10.11.1.2"
```

Generate basic OpenVPN config:

```bash
./bin/generate-config.sh
```

Change ownership:

```bash
sudo chown -R "${USER}:${USER}" ./ovpn0
```

At this point, OpenVPN server config `./ovpn0/server/openvpn.conf` should look something like this:

```
server 10.8.0.0 255.255.255.0
verb 3
key /etc/openvpn/pki/private/vpn.example.com.key
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/vpn.example.com.crt
dh /etc/openvpn/pki/dh.pem
tls-auth /etc/openvpn/pki/ta.key
key-direction 0
keepalive 10 60
persist-key
persist-tun

proto tcp
# Rely on Docker to do port mapping, internally always 1194
port 1194
dev tun0
status /tmp/openvpn-status.log

user nobody
group nogroup
cipher AES-256-CBC
auth SHA384
comp-lzo no

### Push Configurations Below
push "dhcp-option DNS 10.11.1.2"
push "comp-lzo no"

### Extra Configurations Below
topology subnet
```

Note how there are no routes configured to be pushed to clients. If we use the config file as it is, we will be able to access the VPN server and use it as the default gateway on clients, but we will not be able to access the homelab subnet `10.11.1.0/24`.

Update `./ovpn0/server/openvpn.conf` and add `push "route 10.11.1.0 255.255.255.0"` line. This will allow VPN clients to access the homelab subnet.

```
server 10.8.0.0 255.255.255.0
verb 3
key /etc/openvpn/pki/private/vpn.example.com.key
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/vpn.example.com.crt
dh /etc/openvpn/pki/dh.pem
tls-auth /etc/openvpn/pki/ta.key
key-direction 0
keepalive 10 60
persist-key
persist-tun

proto tcp
# Rely on Docker to do port mapping, internally always 1194
port 1194
dev tun0
status /tmp/openvpn-status.log

user nobody
group nogroup
cipher AES-256-CBC
auth SHA384
comp-lzo no

### Push Configurations Below
push "route 10.11.1.0 255.255.255.0"
push "dhcp-option DNS 10.11.1.2"
push "comp-lzo no"

### Extra Configurations Below
topology subnet
```

Generate a client config (can be repeated for any new client):

```bash
export CLIENT_NAME=android
./bin/add-client.sh
```

Set the Kubernetes secrets. Prepend with `REPLACE=true` to update the existing ones:

```bash
./bin/set-secrets.sh
```

Note: VPN config, certificates and keys are stored in the `ovpn0` directory on the machine that was used to run the commands.

## Deploy OpenVPN on Kubernetes

Use `kubectl` to install OpenVPN. See [openvpn-deployment.yaml](./openvpn-deployment.yaml). This will create `PriorityClass`, `Service` and `Deployment` resources, as well as use `loadBalancerIP: 10.11.1.53` from the [MetalLB address pool](../metallb/metallb-config-map.yml).

```bash
kubectl apply -f openvpn-deployment.yaml
```

List pods and services to verify.

```bash
kubectl get po -n openvpn
NAME                      READY   STATUS    RESTARTS   AGE
openvpn-8f548449f-cbqxm   1/1     Running   0          43m
```

```bash
kubectl get svc -n openvpn
NAME      TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)           AGE
openvpn   LoadBalancer   10.107.175.151   10.11.1.53    31194:31844/TCP   43m 
```

## Configure Mikrotik Router

We want to allow connections from the Internet to the OpenVPN service IP `10.11.1.53`. In this case, we have to configure a destination address translation rule on our Mikrotik router.

Create a destination NAT rule:

```bash
/ip firewall nat add chain=dstnat \
  action=dst-nat \
  in-interface=ether1_isp \
  dst-port=31194 \
  to-addresses=10.11.1.53 \
  to-ports=31194 \
  protocol=tcp \
  comment="Allow public to OpenVPN"
```

## Test VPN Access from Android Client

Download **OpenVPN Connect** app from [Google Play](https://play.google.com/store/apps/details?id=net.openvpn.openvpn).

Import `./ovpn0/android.ovpn` client configuration file and connect to the VPN server.

Check pod logs to verify:

```
kubectl -n openvpn logs $(kubectl -n openvpn get po -o name)

Checking IPv6 Forwarding
Sysctl error for disable_ipv6, please run docker with '--sysctl net.ipv6.conf.all.disable_ipv6=0'
Sysctl error for default forwarding, please run docker with '--sysctl net.ipv6.conf.default.forwarding=1'
Sysctl error for all forwarding, please run docker with '--sysctl net.ipv6.conf.all.forwarding=1'
Running 'openvpn --config /etc/openvpn/openvpn.conf --client-config-dir /etc/openvpn/ccd '
2022-02-16 01:36:44 DEPRECATED OPTION: --cipher set to 'AES-256-CBC' but missing in --data-ciphers (AES-256-GCM:AES-128-GCM). Future OpenVPN version will ignore --cipher for cipher negotiations. Add 'AES-256-CBC' to --data-ciphers or change --cipher 'AES-256-CBC' to --data-ciphers-fallback 'AES-256-CBC' to silence this warning.
2022-02-16 01:36:44 OpenVPN 2.5.4 x86_64-alpine-linux-musl [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [MH/PKTINFO] [AEAD] built on Nov 15 2021
2022-02-16 01:36:44 library versions: OpenSSL 1.1.1l  24 Aug 2021, LZO 2.10
2022-02-16 01:36:44 Diffie-Hellman initialized with 2048 bit key
2022-02-16 01:36:44 Outgoing Control Channel Authentication: Using 384 bit message hash 'SHA384' for HMAC authentication
2022-02-16 01:36:44 Incoming Control Channel Authentication: Using 384 bit message hash 'SHA384' for HMAC authentication
2022-02-16 01:36:44 TUN/TAP device tun0 opened
2022-02-16 01:36:44 /sbin/ip link set dev tun0 up mtu 1500
2022-02-16 01:36:44 /sbin/ip link set dev tun0 up
2022-02-16 01:36:44 /sbin/ip addr add dev tun0 10.8.0.1/24
2022-02-16 01:36:44 Could not determine IPv4/IPv6 protocol. Using AF_INET
2022-02-16 01:36:44 Socket Buffers: R=[87380->87380] S=[16384->16384]
2022-02-16 01:36:44 Listening for incoming TCP connection on [AF_INET][undef]:1194
2022-02-16 01:36:44 TCPv4_SERVER link local (bound): [AF_INET][undef]:1194
2022-02-16 01:36:44 TCPv4_SERVER link remote: [AF_UNSPEC]
2022-02-16 01:36:44 GID set to nogroup
2022-02-16 01:36:44 UID set to nobody
2022-02-16 01:36:44 MULTI: multi_init called, r=256 v=256
2022-02-16 01:36:44 IFCONFIG POOL IPv4: base=10.8.0.2 size=252
2022-02-16 01:36:44 MULTI: TCP INIT maxclients=1024 maxevents=1028
2022-02-16 01:36:44 Initialization Sequence Completed
2022-02-16 01:37:15 Outgoing Control Channel Authentication: Using 384 bit message hash 'SHA384' for HMAC authentication
2022-02-16 01:37:15 Incoming Control Channel Authentication: Using 384 bit message hash 'SHA384' for HMAC authentication
2022-02-16 01:37:15 TCP connection established with [AF_INET]10.11.1.35:15520
2022-02-16 01:37:15 10.11.1.35:15520 TLS: Initial packet from [AF_INET]10.11.1.35:15520, sid=27615aef 0df1177d
2022-02-16 01:37:15 10.11.1.35:15520 VERIFY OK: depth=1, CN=vpn.example.com
2022-02-16 01:37:15 10.11.1.35:15520 VERIFY OK: depth=0, CN=android
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_VER=3.git::d3f8b18b:Release
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_PLAT=android
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_NCP=2
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_TCPNL=1
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_PROTO=30
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_CIPHERS=AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305:AES-256-CBC
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_IPv6=0
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_AUTO_SESS=1
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_GUI_VER=net.openvpn.connect.android_3.2.6-7729
2022-02-16 01:37:15 10.11.1.35:15520 peer info: IV_SSO=webauth,openurl
2022-02-16 01:37:15 10.11.1.35:15520 WARNING: 'link-mtu' is used inconsistently, local='link-mtu 1588', remote='link-mtu 1587'
2022-02-16 01:37:15 10.11.1.35:15520 WARNING: 'comp-lzo' is present in local config but missing in remote config, local='comp-lzo'
2022-02-16 01:37:15 10.11.1.35:15520 Control Channel: TLSv1.3, cipher TLSv1.3 TLS_AES_256_GCM_SHA384, peer certificate: 2048 bit RSA, signature: RSA-SHA256
2022-02-16 01:37:15 10.11.1.35:15520 [android] Peer Connection Initiated with [AF_INET]10.11.1.35:15520
2022-02-16 01:37:15 android/10.11.1.35:15520 MULTI_sva: pool returned IPv4=10.8.0.2, IPv6=(Not enabled)
2022-02-16 01:37:15 android/10.11.1.35:15520 MULTI: Learn: 10.8.0.2 -> android/10.11.1.35:15520
2022-02-16 01:37:15 android/10.11.1.35:15520 MULTI: primary virtual IP for android/10.11.1.35:15520: 10.8.0.2
2022-02-16 01:37:15 android/10.11.1.35:15520 Data Channel: using negotiated cipher 'AES-256-GCM'
2022-02-16 01:37:15 android/10.11.1.35:15520 Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
2022-02-16 01:37:15 android/10.11.1.35:15520 Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
2022-02-16 01:37:15 android/10.11.1.35:15520 SENT CONTROL [android]: 'PUSH_REPLY,route 10.11.1.0 255.255.255.0,dhcp-option DNS 10.11.1.2,dhcp-option DNS 10.11.1.3,comp-lzo no,route-gateway 10.8.0.1,topology subnet,ping 10,ping-restart 60,ifconfig 10.8.0.2 255.255.255.0,peer-id 0,cipher AES-256-GCM' (status=1)
2022-02-16 01:37:15 android/10.11.1.35:15520 PUSH: Received control message: 'PUSH_REQUEST'
2022-02-16 01:38:04 android/10.11.1.35:15520 Connection reset, restarting [0]
2022-02-16 01:38:04 android/10.11.1.35:15520 SIGUSR1[soft,connection-reset] received, client-instance restarting
```

At this point we should be able to access internal homelab services as well as route all traffic through the VPN gateway because of `redirect-gateway def1` client config.

If default routing is not desired, then `redirect-gateway def1` could be removed from client config. We would still be able to access services on `10.11.1.0/24`.

## Configuration Variables

| Variable          | Information                        | Default     |
|:------------------|:-----------------------------------|:------------|
| VPN_HOSTNAME      | VPN hostname                       |             |
| VPN_PORT          | VPN port for Kubernetes service    | 31194       |
| VPN_PROTOCOL      | VPN server protocol                | tcp         |
| DNS_SERVER        | DNS server IP address (CloudFlare) | 1.1.1.1     |
| NETWORK_CIDR      | VPN server subnet                  | 10.8.0.0/24 |
| CLIENT_NAME       | VPN client name                    |             |
| APP_VERSION       | OpenVPN version (docker build tag) | latest      |
