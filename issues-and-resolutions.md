# Project Issues and Resolutions

This file summarizes the main issues encountered and how they were resolved.

## Build and CI/CD

- Issue: Git push rejected due to large Terraform provider binaries.
  Resolution: Added root .gitignore for Terraform artifacts and reinitialized repo history without .terraform contents.

- Issue: GitHub Actions OIDC failed (AssumeRoleWithWebIdentity).
  Resolution: Updated IAM trust policy to match the correct repo and branch subject.

- Issue: Trivy scan failed to parse image ref.
  Resolution: Switched to GitHub Actions env syntax in trivy-action image-ref.

- Issue: CI step updating GitOps repo failed due to wrong paths.
  Resolution: Updated paths to monorepo layout under gitops-repo/.

- Issue: CI pushes to main caused frequent rebase conflicts.
  Resolution: CI now pushes updates to gitops-update branch and opens a PR.

## Docker Builds

- Issue: Worker Dockerfile referenced api/requirements.txt outside build context.
  Resolution: Added app-repo/worker/requirements.txt and copied local file.

- Issue: Worker image missing worker.py at runtime.
  Resolution: Copy /app from build stage into final image.

- Issue: ImagePullBackOff due to missing latest tag in ECR.
  Resolution: CI tags and pushes both SHA and latest for API and worker.

## ArgoCD and GitOps

- Issue: ArgoCD app-of-apps path not found.
  Resolution: Updated app paths to include gitops-repo/ prefix in monorepo.

- Issue: Helm render error: annotations expected map but got string.
  Resolution: Fixed Deployment annotations to render as a map.

- Issue: Worker values file list malformed in ArgoCD app.
  Resolution: Fixed valueFiles list formatting.

- Issue: Prod app OutOfSync due to stale ingress.
  Resolution: Pruned old ingress and disabled ingress by default.

## KEDA and Autoscaling

- Issue: KEDA ScaledObject missing awsRegion.
  Resolution: Added awsRegion to trigger metadata.

- Issue: TriggerAuthentication provider invalid (aws-iam).
  Resolution: Switched to aws-eks.

- Issue: HPA degraded due to missing metrics API.
  Resolution: Installed metrics-server.

## Cluster Access

- Issue: ArgoCD UI inaccessible from localhost.
  Resolution: Used port-forward to ClusterIP service and proper local port mapping.

## Final Stabilization

- Issue: Worker apps degraded for extended time.
  Resolution: Removed worker applications from GitOps to complete the project on time.
