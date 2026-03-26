Prometheus & Grafana setup

We install `kube-prometheus-stack` and `loki` via Helm (see infra-repo/k8s/INSTALLATION.md).

Example dashboards to add:
- CPU usage and requests per pod
- Memory usage
- Request rate / latency for API
- SQS queue depth

Create alerts in Prometheus for:
- High error rate
- High latency
- SQS queue depth above threshold

Grafana provisioning:
- Use a Prometheus datasource and import JSON dashboards or use Helm values to provision dashboards.
