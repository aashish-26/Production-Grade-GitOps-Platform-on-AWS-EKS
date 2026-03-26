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

### 4. Deploy GitOps Applications

```bash
kubectl apply -f argocd/app-of-apps.yaml
```

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

## Resume Highlights

* Designed and implemented GitOps-based CI/CD platform using ArgoCD on AWS EKS
* Built microservices architecture with async processing using AWS SQS
* Implemented autoscaling using HPA and KEDA
* Integrated observability using Prometheus, Grafana, and Loki
* Enabled automated deployments, rollback, and drift detection
