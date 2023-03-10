#!/usr/bin/env bash

set -ex

source bin/_helpers.sh
ensure-environment "VPN_HOSTNAME NAMESPACE"

cmd_delete="kubectl -n ${NAMESPACE} delete"
cmd_create="kubectl -n ${NAMESPACE} create"

if [[ ! -z "${REPLACE}" ]] && [[ "${REPLACE}" == "true" ]]; then
  echo "Removing all previous secrets and configmaps"
  eval "${cmd_delete}" secret ovpn0-key
  eval "${cmd_delete}" secret ovpn0-cert
  eval "${cmd_delete}" secret ovpn0-pki
  eval "${cmd_delete}" configmap ovpn0-conf
  eval "${cmd_delete}" configmap ccd0
fi

eval "${cmd_create}" secret generic ovpn0-key \
  --from-file=ovpn0/server/pki/private/"${VPN_HOSTNAME}".key

eval "${cmd_create}" secret generic ovpn0-cert \
  --from-file=ovpn0/server/pki/issued/"${VPN_HOSTNAME}".crt

eval "${cmd_create}" secret generic ovpn0-pki \
  --from-file=ovpn0/server/pki/ca.crt \
  --from-file=ovpn0/server/pki/dh.pem \
  --from-file=ovpn0/server/pki/ta.key

eval "${cmd_create}" configmap ovpn0-conf \
  --from-file=ovpn0/server/

eval "${cmd_create}" configmap ccd0 \
  --from-file=ovpn0/server/ccd
