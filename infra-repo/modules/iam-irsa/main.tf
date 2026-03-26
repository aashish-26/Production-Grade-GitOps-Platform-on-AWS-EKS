locals {
  provider_host = replace(var.oidc_provider_url, "https://", "")
  sub_claim_key = "${local.provider_host}:sub"
  role_name     = "${var.name_prefix}-${var.service_account_namespace}-${var.service_account_name}"
}

resource "aws_iam_role" "irsa_role" {
  name               = local.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            (local.sub_claim_key) = "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.policy_arns)
  role     = aws_iam_role.irsa_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  count = var.inline_policy != "" ? 1 : 0
  name  = "${aws_iam_role.irsa_role.name}-inline"
  role  = aws_iam_role.irsa_role.id
  policy = var.inline_policy
}
