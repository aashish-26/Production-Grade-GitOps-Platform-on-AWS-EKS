# Production-Grade GitOps Platform on AWS EKS

## Overview

This project implements a production-grade platform using Kubernetes (EKS), GitOps (ArgoCD), and CI/CD (GitHub Actions).

It simulates a real-world system with multiple microservices, asynchronous processing, autoscaling, and full observability.

---

## Architecture

* CI: GitHub Actions builds, scans, and pushes images to ECR
* CD: ArgoCD pulls manifests from Git and deploys to EKS
* Workloads: API + Worker services
* Async Processing: AWS SQS
* Scaling: HPA + KEDA
* Observability: Prometheus, Grafana, Loki

---

## Tech Stack

* AWS: EKS, ECR, SQS, IAM, VPC
* Kubernetes
* ArgoCD
* GitHub Actions
* Helm
* Prometheus, Grafana, Loki
* Trivy
* External Secrets

---

## Key Features

* GitOps-based deployments using ArgoCD
* Multi-environment setup (dev/staging/prod)
* Microservices architecture (API + worker)
* Asynchronous processing using SQS
* Autoscaling using HPA and KEDA
* Centralized logging using Loki
* Security scanning with Trivy
* Rollback using ArgoCD

---

## Setup Instructions

### 1. Provision Infrastructure

Run Terraform:

```bash
terraform init
terraform apply
```

### 2. Configure kubectl

```bash
aws eks update-kubeconfig --region <region> --name <cluster>
```

### 3. Install ArgoCD

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 3.1 Access ArgoCD UI (private clusters)

If your nodes are in private subnets, use port-forwarding:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Open https://localhost:8080

Get the admin password (PowerShell):

```powershell
$pw = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($pw))
```

### 4. Deploy GitOps Applications

```bash
kubectl apply -f argocd/app-of-apps.yaml
```

### 5. Install Monitoring (Prometheus, Grafana, Loki)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create ns monitoring
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
helm install loki grafana/loki-stack -n monitoring
```

### 6. Install KEDA (event-driven autoscaling)

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

kubectl create ns keda
helm install keda kedacore/keda -n keda
```

---

## Helm Usage in This Project

Helm packages the Kubernetes manifests for each service. ArgoCD renders the charts
and applies them per environment.

- API chart: gitops-repo/helm/api-service
- Worker chart: gitops-repo/helm/worker-service

---

## Why SQS

SQS decouples the API from background processing:

1) API receives a request
2) API pushes a message to SQS
3) Worker consumes messages and processes jobs

This buffers traffic spikes, keeps the API responsive, and enables worker
autoscaling with KEDA.

---

## Implementation Phases

1. Infrastructure provisioning
2. Kubernetes setup
3. Application development
4. CI pipeline setup
5. GitOps deployment
6. Autoscaling and monitoring

---

## Screenshots

* ArgoCD dashboard
* Grafana dashboards
* CI pipeline execution

---

## Monitoring Dashboards and Alerts

Dashboards and alerts are stored in:

- gitops-repo/monitoring/dashboards
- gitops-repo/monitoring/alerts

Apply them to the cluster:

```bash
kubectl apply -f gitops-repo/monitoring/dashboards/dashboard-configmaps.yaml
kubectl apply -f gitops-repo/monitoring/alerts/prometheus-rules.yaml
```

Note: The SQS queue depth panel and alert require an SQS metric exporter or a
Prometheus integration that exposes `sqs_approximate_number_of_messages_visible`.

---

## Repo Split (Optional)

If you want to split into separate repos (app/infra/gitops), see:

- repo-split.md

---

## Resume Highlights

* Designed and implemented GitOps-based CI/CD platform using ArgoCD on AWS EKS
* Built microservices architecture with async processing using AWS SQS
* Implemented autoscaling using HPA and KEDA
* Integrated observability using Prometheus, Grafana, and Loki
* Enabled automated deployments, rollback, and drift detection
