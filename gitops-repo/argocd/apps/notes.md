Deployment strategy notes

- `dev`: auto-sync enabled for fast feedback. CI updates `environments/dev` values.
- `staging`: require PR-based promotion. Configure branch protection and PR validation.
- `prod`: manual approval. Either protect the branch and allow only specific merge ops, or disable automated sync in ArgoCD and use approvals.

Promotion flow (recommended):
1. CI pushes image tag update to `environments/dev` and ArgoCD auto-syncs.
2. When ready, create image promotion PR that updates `environments/staging/values.yaml` with the same immutable tag.
3. After staging verification, create PR to `environments/prod/values.yaml` and require manual approval or ArgoCD App sync via UI/API.

Approvals:
- Use GitHub branch protection and required reviewers for `prod` and `staging` branches as desired.
- Optionally, enable ArgoCD App Sync waves or use argo-rollouts for controlled canary/blue-green strategies.
