[[Back to Index Page](../README.md)]

# Alertmanager

See https://www.prometheus.io/docs/alerting/latest/alertmanager/

The Alertmanager handles alerts sent by client applications such as the Prometheus server.

## Deploy Alertmanager

Alertmanager uses the Incoming Webhooks feature of Slack, therefore you need to set it up if you want to receive Slack alerts.

Update the config map `alertmanager-config-map.yml` and specify your incoming webhook URL. Then deploy Alertmanager:

```bash
kubectl apply -f ./alertmanager
```
