#!/bin/bash
# AUTHOR:   Tomas Nevar (tomas@lisenet.com)
# NAME:     break-kubernetes-cluster.sh
# VERSION:  1.0
# DATE:     13/02/2022 (dd/mm/yy)
# LICENCE:  Copyleft free software
set -eu

BINARY_ARRAY=(kubectl)
FUNCTION_ARRAY=(
break_controlplane_1
break_controlplane_2
break_controlplane_3
break_controlplane_4
)

function sanity_checks()
{
  for package in "${BINARY_ARRAY[@]}"; do
    # Check for binary installation
    type "${package}" >/dev/null 2>&1 || { echo >&2 "I require ${package} but it's not installed. Aborting."; exit 1; };
  done
}

# "There is more than one way to skin a cat"

function break_controlplane_1()
{
  # Break kube-scheduler
  local function_name="break-controlplane-1"
  local config_file="/etc/kubernetes/manifests/kube-scheduler.yaml"

  if [ -s "${config_file}" ]; then
    # Break something
    sed -i 's/image:/imaginaerum:/g' "${config_file}"

    # Do something
    kubectl run "busybox-${function_name}" --image=busybox -- sleep 3600

    # Ask to fix something
    printf "%s\\n%s\\n" "TasK: ${function_name}" "There is a pod 'busybox-${function_name}' scheduled but not running, fix the issue."
  fi
}

function break_controlplane_2()
{
  # Break kubelet
  local function_name="break-controlplane-2"
  local config_file="/etc/kubernetes/kubelet.conf"

  if [ -s "${config_file}" ]; then
    # Break something
    sed -i 's/6443/31337/g' "${config_file}"

    # Do something
    sudo systemctl restart kubelet

    # Ask to fix something
    printf "%s\\n" "Task: ${function_name}" "Wait for 30s. There is a cluster node with a status of 'NotReady', fix the issue."
  fi
}

function break_controlplane_3()
{
  # Break etcd
  local function_name="break-controlplane-3"
  local config_file="/etc/kubernetes/pki/etcd/server.crt"

  if [ -s "${config_file}" ]; then
    # Break something
    mv "${config_file}" "${config_file}.backup"

    # Do something
    kubectl -n kube-system delete "$(kubectl -n kube-system get po -l component=etcd -o name)"

    # Ask to fix something
    printf "%s\\n" "Task: ${function_name}" "There is a problem with etcd, fix the issue."
  fi
}

function break_controlplane_4()
{
  # Break coredns
  local function_name="break-controlplane-4"

  # Break something
  kubectl -n kube-system get cm/coredns -o yaml|sed 's/forward.*/forward\ \. 0.0.0.0 \{/g'|kubectl apply -f - > /dev/null

  # Do something
  kubectl -n kube-system scale deploy/coredns --replicas=0 > /dev/null

  # Ask to fix something
  printf "%s\\n" "Task: ${function_name}" "There is a problem with coredns, fix the issue."
}

main()
{
  sanity_checks

  # Break something at random
  eval "${FUNCTION_ARRAY[RANDOM%4]}"
}
main "$@"
