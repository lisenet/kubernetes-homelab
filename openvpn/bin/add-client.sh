#!/usr/bin/env bash

set -ex

source bin/_helpers.sh
ensure-environment "CLIENT_NAME"

if [[ ! -z "${USE_RSA}" ]] && [[ "${USE_RSA}" == "true" ]]; then
  echo "Will generate RSA certificates instead of ECC"
else
  echo "Will generate ECC certificates"
  ARGS="-e EASYRSA_ALGO=ec -e EASYRSA_CURVE=secp384r1"
fi

echo "Generating client certificate and config..."
docker run "${ARGS}" \
  --net=none --rm -it -v "${PWD}/ovpn0:/etc/openvpn" "lisenet/openvpn:${APP_VERSION}" easyrsa build-client-full "${CLIENT_NAME}"

docker run --net=none --rm -v "${PWD}/ovpn0:/etc/openvpn" "lisenet/openvpn:${APP_VERSION}" ovpn_getclient "${CLIENT_NAME}" > "ovpn0/${CLIENT_NAME}.ovpn"

