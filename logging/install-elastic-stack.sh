#!/bin/bash
set -eu

# See https://github.com/lisenet/kubernetes-homelab

STACK_VERSION="7.16.1"
NAMESPACE="logging"

if ! kubectl get ns logging > /dev/null; then
  kubectl create ns logging
else
  printf "%s\\n" "Namespace 'logging' already exists"
fi

if [ -e ./elastic-certificates-secret.yml ]; then
  kubectl apply -f ./elastic-certificates-secret.yml
else
  printf "%s\\n" "Certificates files not found"
fi

if [ -e ./elastic-credentials-secret.yml ]; then
  kubectl apply -f ./elastic-credentials-secret.yml
else
  printf "%s\\n" "Credentials files not found"
fi

if ! helm repo list|grep elastic > /dev/null; then
  helm repo add elastic https://helm.elastic.co
else
  printf "%s\\n" "Helm repository for 'elastic  already exists"
fi

helm repo update

if [ -e ./values-elasticsearch.yml ]; then
  printf "\\n%s\\n" "Deploying Elasticsearch"
  helm upgrade --install elasticsearch \
    elastic/elasticsearch \
    --namespace "${NAMESPACE}" \
    --version "${STACK_VERSION}" \
    --values ./values-elasticsearch.yml \
    --set service.type="LoadBalancer" \
    --set service.LoadBalancerIP="10.11.1.59"
else
  printf "%s\\n" "Helm values file for Elasticsearch not found"
  exit 1
fi

if [ -e ./values-kibana.yml ]; then
  printf "\\n%s\\n" "Deploying Kibana"
  helm upgrade --install kibana \
    elastic/kibana \
    --namespace "${NAMESPACE}" \
    --version "${STACK_VERSION}" \
    --values ./values-kibana.yml \
    --set service.type="LoadBalancer" \
    --set service.LoadBalancerIP="10.11.1.58"
else
  printf "%s\\n" "Helm values file for Kibana not found"
  exit 1
fi

if [ -e ./values-filebeat.yml ]; then
  printf "\\n%s\\n" "Deploying Filebeat"
  helm upgrade --install filebeat \
    elastic/filebeat \
    --namespace "${NAMESPACE}" \
    --version "${STACK_VERSION}" \
    --values ./values-filebeat.yml
else
  printf "%s\\n" "Helm values file for Filebeat not found"
  exit 1
fi

# Stop here
exit 0

if [ -e ./values-logstash.yml ]; then
  printf "\\n%s\\n" "Deploying Logstash"
  helm upgrade --install logstash \
    elastic/logstash \
    --namespace "${NAMESPACE}" \
    --version "${STACK_VERSION}" \
    --values ./values-logstash.yml
else
  printf "%s\\n" "Helm values file for Logstash not found"
  exit 1
fi
