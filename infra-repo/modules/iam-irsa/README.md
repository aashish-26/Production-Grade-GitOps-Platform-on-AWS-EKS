# iam-irsa

Reusable Terraform module to create an IAM role usable with Kubernetes IRSA (IAM Roles for Service Accounts).

Usage example (call from an environment root):

```hcl
module "api_irsa" {
  source = "../../modules/iam-irsa"

  name_prefix                = "api-role"
  service_account_namespace  = "default"
  service_account_name       = "api-sa"
  oidc_provider_arn          = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.REGION.amazonaws.com/id/EXAMPLE"
  oidc_provider_url          = "https://oidc.eks.REGION.amazonaws.com/id/EXAMPLE"
  policy_arns                = ["arn:aws:iam::aws:policy/AmazonSQSFullAccess"]
  tags = {
    Project = "gitops"
  }
}
```

Notes:
- This module expects an existing OIDC provider for the EKS cluster; the provider ARN and URL must be supplied.
- The module creates an IAM role with a trust policy scoped to the specified service account.
- Attach managed policies via `policy_arns` or pass an inline policy JSON string via `inline_policy`.
