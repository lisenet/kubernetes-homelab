[[Back to Index Page](../README.md)]

# Speedtest to InfluxDB

Run speedtest-cli Docker images using a cronjob and store speedtest results in InfluxDB. Use Grafana with InfluxDB datasource to view data.

See https://github.com/sivel/speedtest-cli and https://github.com/influxdata/influxdb

![Grafana Dashboard Speedtest](../images/grafana/grafana-dashboard-speedtest.png)

## Kubernetes Deployment

Create a namespace:

```bash
kubectl create ns speedtest
```

### Setup InfluxDB

```bash
kubectl apply -f influxdb-pvc.yml
kubectl apply -f influxdb-service.yml
kubectl apply -f influxdb-statefulset.yml
```

Configure InfluxDB:

```bash
kubectl port-forward -n speedtest service/influxdb 8086:8086

influx setup --host http://127.0.0.1:8086/ \
  --org kubernetes-homelab \
  --username admin \
  --bucket speedtest \
  --retention 0
```

Create a bucket to store speedtest results:

```bash
influx bucket create --name speedtest --retention 0
```

Create a v1 user and a password:

```bash
influx v1 auth create \
  --username speedtest \
  --read-bucket $(influx bucket list --name speedtest --hide-headers|cut -f1) \
  --write-bucket $(influx bucket list --name speedtest --hide-headers|cut -f1)
```

Create a v1 DB retention policy:

```bash
influx v1 dbrp create \
  --bucket-id $(influx bucket list --name speedtest --hide-headers|cut -f1) \
  --db speedtest \
  --rp 0 \
  --default
```

### Deploy speedtest-cli

Update the file `speedtest-secret.yml` to use the password that you set up for the v1 user, and deploy the application.

```bash
kubectl apply -f speedtest-secret.yml
kubectl apply -f speedtest-cronjob.yml
```

## InfluxDB Variables

| Variable          | Information                     |
|:------------------|:--------------------------------|
| INFLUXDB_HOST     | InfluxDB server FQDN/IP address |
| INFLUXDB_PORT     | InfluxDB server port            |
| INFLUXDB_DATABASE | Database name                   |
| INFLUXDB_USERNAME | Username                        |
| INFLUXDB_PASSWORD | Password                        |

## Grafana Dashboard

See [`grafana-dashboard-speedtest.json`](./grafana-dashboard-speedtest.json)