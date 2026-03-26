# Kubernetes base setup

This file contains step-by-step commands and notes to install ArgoCD, AWS Load Balancer Controller (ALB controller), External Secrets, KEDA, and monitoring on the EKS cluster produced by Terraform.

Prerequisites
- AWS CLI configured with an account that can assume the infra management role
- `kubectl` installed
- `helm` installed
- `aws-iam-authenticator` (optional)
- kubeconfig is configured for the EKS cluster (see below)

Obtain kubeconfig
```bash
# TODO: USER_ACTION_REQUIRED - replace <region> and <cluster_name>
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

1) Create standard namespaces
```bash
kubectl create ns argocd
kubectl create ns dev
kubectl create ns staging
kubectl create ns prod
kubectl create ns monitoring
kubectl create ns external-secrets
```

2) Install ArgoCD (recommended: use upstream manifest and then configure TLS/RBAC)
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Wait for components to become ready. Expose the ArgoCD server using port-forward or an ingress with ALB.
kubectl -n argocd wait --for=condition=Available deployment/argocd-server --timeout=120s
```

3) Install External Secrets Operator (to sync AWS Secrets Manager)
```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets --namespace external-secrets
```

4) Install KEDA
```bash
helm repo add keda https://kedacore.github.io/charts
helm repo update
helm install keda keda/keda --namespace keda --create-namespace
```

5) Install AWS Load Balancer Controller (ALB ingress) - requires IRSA

# Steps (high level):
# 1. Ensure OIDC provider is available for the EKS cluster.
# 2. Create an IAM role for the service account with the ALB controller policy.
# 3. Create Kubernetes service account with annotation for the IAM role ARN.
# 4. Install Helm chart pointing at that service account.

# TODO: USER_ACTION_REQUIRED - Create IAM role for ALB controller via Terraform or aws cli. Example (short):

# Example helm install (replace placeholders):
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Replace <iam_role_arn> and <cluster_name>, <region>
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: "<iam_role_arn>"
EOF

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
  --set clusterName=<cluster_name> \
  --set serviceAccount.create=false \
  --set region=<region> \
  --set vpcId=<vpc-id>

# Note: The IAM role must include the AWS managed policy: "AmazonEKSLoadBalancerControllerPolicy" or a least-privilege equivalent.

6) Install monitoring stack (Prometheus + Grafana + Prometheus-operator)
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install kube-prom-stack prometheus-community/kube-prometheus-stack -n monitoring
helm install loki grafana/loki-stack -n monitoring
```

7) Verify
```bash
kubectl get pods -n argocd
kubectl get pods -n monitoring
kubectl get pods -n external-secrets
kubectl get pods -n keda
```

Comments
- IRSA: create IAM roles using Terraform when possible to keep infra-as-code.
- ALB Controller: requires a public subnet for ALB to provision ALBs for internet-facing workloads.
- External Secrets: configure a ClusterSecretStore (manifest provided in gitops-repo).

