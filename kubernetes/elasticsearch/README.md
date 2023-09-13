# Elastic Stack for Logging

Note: we have migrated from Elasticsearch to Loki because Elastic no longer support deployment via Helm. These configuration files are left here for references but are no longer maintained.

See https://github.com/elastic/helm-charts (the repository has been archived in 2023).

## Pre-requisites

Add Helm repository:

```bash
helm repo add elastic https://helm.elastic.co
```

Create `logging` namespace:

```bash
kubectl create namespace logging
```

## Deploy Elasticsearch using Helm

### Create Secrets

Create a secret to store Elasticsearch credentials:

```bash
kubectl apply -f ./elastic-credentials-secret.yml
```

Create a secret to store Elasticsearch SSL certificates. We are using our [homelab Root CA](https://www.lisenet.com/2021/create-your-own-certificate-authority-ca-for-homelab-environment/) to sign the certificate.

```bash
kubectl apply -f ./elastic-certificates-secret.yml
```

### Deploy Elasticsearch

Deploy a single node Elasticsearch with authentication, certificates for TLS and custom [values](./values-elasticsearch.yml):

```bash
helm upgrade --install elasticsearch \
  elastic/elasticsearch \
  --namespace logging \
  --version "7.17.1" \
  --values ./values-elasticsearch.yml
```

## Deploy Kibana using Helm

Deploy Kibana using authentication and TLS to connect to Elasticsearch (see [values](./values-kibana.yml)):

```bash
helm upgrade --install kibana \
  elastic/kibana \
  --namespace logging \
  --version "7.17.1" \
  --values ./values-kibana.yml
```

## Deploy Filebeat using Helm

Deploy Filebeat using authentication and TLS to connect to Elasticsearch (see [values](./values-filebeat.yml)).

```bash
helm upgrade --install filebeat \
  elastic/filebeat \
  --namespace logging \
  --version "7.17.1" \
  --values ./values-filebeat.yml
```

# Essential Reading

https://www.elastic.co/guide/en/elasticsearch/reference/7.17/configuring-stack-security.html

https://www.elastic.co/guide/en/elasticsearch/reference/7.17/security-settings.html

