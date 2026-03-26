# Rollback and Failure Runbook

Scenario: a bad image is deployed to an environment (staging or prod) and health checks fail.

1) Identify failing application in ArgoCD
- Open ArgoCD UI, select the application and check Sync status and Health.

2) Quick rollback (ArgoCD UI)
- In the ArgoCD app, use the "Rollback" button to roll back to the previous revision.

3) Git-based rollback (recommended)
- Revert the commit in the GitOps repo that introduced the bad image tag and merge to the environment branch.
- Example:
  ```bash
  git clone <GITOPS_REPO>
  cd <repo>
  git checkout main
  git revert <bad-commit-hash> -m "revert: rollback bad image"
  git push
  ```
- ArgoCD will detect the change and reconcile back to the previous working image.

4) Post-rollback actions
- Investigate root cause, examine Trivy/Aqua scan output and application logs.
- Add additional tests to CI to catch the issue earlier.

5) Automated safety nets
- Use ArgoCD health checks and automated rollbacks based on probe failures.
- Use image promotion gating to prevent untested images from reaching prod.

# Testing rollbacks
- Test rollback in staging before enabling automated production rollbacks.

# Note
- Always prefer Git revert for auditability; UI rollbacks are faster but less auditable unless you also push a revert commit.
