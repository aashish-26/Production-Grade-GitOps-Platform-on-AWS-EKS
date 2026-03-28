# Repo Split Guide (App / Infra / GitOps)

This project currently lives in a single repo. Use the helper script to split it into three repos.

## Why split
- Cleaner ownership boundaries
- CI/CD pipelines are simpler
- GitOps repo stays clean and auditable

## Script

Run from repo root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\split-repos.ps1
```

This creates:

```
split-repos/
  app-repo/
  infra-repo/
  gitops-repo/
```

Each folder is initialized with its own Git history.

## Next steps
1) Create three GitHub repos
2) Add remotes and push from each folder
3) Update ArgoCD to point to the new GitOps repo
4) Update CI to point to the new GitOps repo
