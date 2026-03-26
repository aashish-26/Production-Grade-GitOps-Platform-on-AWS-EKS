ArgoCD Image Updater

Install (Helm):

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd-image-updater argo/argocd-image-updater -n argocd \
  --set config.log.level=info
```

Or using manifest:
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
```

Annotation examples (place on ArgoCD Application or resources):

- To allow image updater to update Helm values, annotate the ArgoCD Application resource:

```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/attribution: "true"
    argocd-image-updater.argoproj.io/credentials: "ecr-creds"
    argocd-image-updater.argoproj.io/image-list: |
      api-service=${ECR_API_REPO}
      worker-service=${ECR_WORKER_REPO}
```

- If you prefer resource-level annotations, add to `Deployment` metadata in the Helm chart (we added `imageUpdater.annotations` in the charts).

Notes:
- Image updater needs access to container registry credentials. For ECR, use an IAM role with permissions and configure credentials in the image-updater config or use an ECR token provider.
- Mark TODOs in app manifests for repo URL and credentials.
