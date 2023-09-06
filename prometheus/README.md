# Prometheus Stack Installation via Helm

## Prerequisites

Before you begin, make sure you have the following prerequisites:

1. A running Kubernetes cluster.
2. Helm installed on your local machine.
3. kubectl installed on your local machine and configured to connect to your Kubernetes cluster.

## Installation Steps
1. Add Prometheus Helm Repository

If you haven't already, add the Prometheus Helm repository to your Helm repositories:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

2. Create Namespace

You can choose to create a separate namespace for the Prometheus stack or use an existing one. For this example, we will create a new namespace called "monitoring":

```bash
kubectl create namespace monitoring
```

3. Install Prometheus Stack

Install the Prometheus stack using Helm. Customize the installation by specifying your own configuration values, such as service names, storage classes, and ingress settings in the values.yaml file.

```bash
helm install prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
```

Replace values.yaml with your customized configuration file.
4. Access Prometheus and Grafana

By default, Prometheus and Grafana services are not exposed externally. You can use port forwarding to access them locally:
Prometheus:

```bash
kubectl port-forward -n monitoring svc/prometheus-stack-prometheus 9090
```

You can now access Prometheus at http://localhost:9090 in your web browser.
Grafana:

```bash
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000
```

You can now access Grafana at http://localhost:3000 in your web browser. The default username and password are both "admin."

## Apply Rules and AlertManagerRules

1. Apply Rules:

```bash
kubectl apply -f gen_rules.yamll
```

2. Apply AlertManagerRules:


```bash
kubectl apply -f mail_secret.yaml
kubectl apply -f alert_manager_config.yaml
```
