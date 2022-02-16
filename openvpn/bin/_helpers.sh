#!/usr/bin/env bash

ensure-environment() {
  if [[ $1 == *"VPN_PORT"* ]] && [[ -z "${VPN_PORT}" ]]; then
    echo "No VPN_PORT specified. Defaulting to 31194"
    VPN_PORT="31194"
  fi

  if [[ $1 == *"VPN_PROTOCOL"* ]] && [[ -z "${VPN_PROTOCOL}" ]]; then
    echo "No VPN_PROTOCOL specified. Defaulting to tcp"
    VPN_PROTOCOL="tcp"
  fi

  if [[ $1 == *"VPN_HOSTNAME"* ]] && [[ -z "${VPN_HOSTNAME}" ]]; then
    echo "Please specify VPN_HOSTNAME This is the hostname or domain pointing at your cluster."
    exit 1
  fi

  if [[ $1 == *"DNS_SERVER"* ]] && [[ -z "${DNS_SERVER}" ]]; then
    echo "No DNS_SERVER specified. Defaulting to 1.1.1.1 (CloudFlare)"
    DNS_SERVER="1.1.1.1"
  fi

  if [[ $1 == *"NETWORK_CIDR"* ]] && [[ -z "${NETWORK_CIDR}" ]]; then
    echo "No NETWORK_CIDR specified. Defaulting to 10.8.0.0/24"
    NETWORK_CIDR="10.8.0.0/24"
  fi

  if [[ $1 == *"NAMESPACE"* ]] && [[ -z "${NAMESPACE}" ]]; then
    echo "No NAMESPACE specified. Defaulting to openvpn"
    NAMESPACE="openvpn"
  fi

  if [[ $1 == *"CLIENT_NAME"* ]] && [[ -z "${CLIENT_NAME}" ]]; then
    echo "Please specify CLIENT_NAME"
    exit 1
  fi

  if [[ $1 == *"APP_VERSION"* ]] && [[ -z "${APP_VERSION}" ]]; then
    echo "No APP_VERSION specified. Defaulting to 2.5"
    APP_VERSION="2.5"
  fi

  VPN_URI=${VPN_PROTOCOL}://${VPN_HOSTNAME}:${VPN_PORT}
}
