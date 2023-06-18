#!/usr/bin/env bash

set -ex

source bin/_helpers.sh
ensure-environment "VPN_PROTOCOL VPN_HOSTNAME VPN_PORT DNS_SERVER NETWORK_CIDR APP_VERSION"

echo "Generating OpenVPN config..."
docker run --net=none --rm -it -v "${PWD}/ovpn0:/etc/openvpn" "lisenet/openvpn:${APP_VERSION}" ovpn_genconfig \
  -u "${VPN_URI}" \
  -C 'AES-256-CBC' -a 'SHA384' \
  -b -n "${DNS_SERVER}" \
  -s "${NETWORK_CIDR}" \
  -e "topology subnet"

echo "Initialising keys..."
docker run --net=none --rm -it -v "${PWD}/ovpn0:/etc/openvpn" "lisenet/openvpn:${APP_VERSION}" ovpn_initpki

docker run --net=none --rm -it -v "${PWD}/ovpn0:/etc/openvpn" "lisenet/openvpn:${APP_VERSION}" ovpn_copy_server_files
