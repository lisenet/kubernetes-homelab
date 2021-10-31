#!/bin/bash
set -e

# Kubecost uses labels to calculate an infrastructure health score.
# This script labels Kubernetes nodes for Kubecost.
# See https://kubernetes.io/docs/reference/labels-annotations-taints/#topologykubernetesiozone

MASTER_NODE_ARRAY=(
srv31
srv32
srv33
)

WORKER_NODE_ARRAY=(
srv34
srv35
srv36
)

CMD="kubectl label node --overwrite"

for i in "${MASTER_NODE_ARRAY[@]}";do
  printf "%s\\n" "${i}"
  ${CMD} "${i}" node.kubernetes.io/instance-type=c5a.large
  ${CMD} "${i}" topology.kubernetes.io/region=eu-west-2
  ${CMD} "${i}" failure-domain.beta.kubernetes.io/region=eu-west-2
done

for i in "${WORKER_NODE_ARRAY[@]}";do
  printf "%s\\n" "${i}"
  ${CMD} "${i}" node.kubernetes.io/instance-type=m5a.large
  ${CMD} "${i}" topology.kubernetes.io/region=eu-west-2
  ${CMD} "${i}" failure-domain.beta.kubernetes.io/region=eu-west-2
done

printf "%s\\n" "Add zone labels"

${CMD} srv31 topology.kubernetes.io/zone=eu-west-2a
${CMD} srv32 topology.kubernetes.io/zone=eu-west-2b
${CMD} srv33 topology.kubernetes.io/zone=eu-west-2c
${CMD} srv34 topology.kubernetes.io/zone=eu-west-2a
${CMD} srv35 topology.kubernetes.io/zone=eu-west-2b
${CMD} srv36 topology.kubernetes.io/zone=eu-west-2c

${CMD} srv31 failure-domain.beta.kubernetes.io/zone=eu-west-2a
${CMD} srv32 failure-domain.beta.kubernetes.io/zone=eu-west-2b
${CMD} srv33 failure-domain.beta.kubernetes.io/zone=eu-west-2c
${CMD} srv34 failure-domain.beta.kubernetes.io/zone=eu-west-2a
${CMD} srv35 failure-domain.beta.kubernetes.io/zone=eu-west-2b
${CMD} srv36 failure-domain.beta.kubernetes.io/zone=eu-west-2c

kubectl get no --show-labels
