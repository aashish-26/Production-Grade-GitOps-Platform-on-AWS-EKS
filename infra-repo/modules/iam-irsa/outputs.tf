output "role_arn" {
  description = "IAM role ARN created for the service account"
  value       = aws_iam_role.irsa_role.arn
}

output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.irsa_role.name
}

output "role_id" {
  description = "IAM role id"
  value       = aws_iam_role.irsa_role.id
}
