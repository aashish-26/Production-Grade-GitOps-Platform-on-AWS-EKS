output "cluster_name" { value = module.eks_mod.cluster_id }
output "cluster_endpoint" { value = module.eks_mod.cluster_endpoint }
output "cluster_certificate_authority_data" {
  value = module.eks_mod.cluster_certificate_authority_data
}
output "node_groups_role_arns" {
  description = "Map of managed node group name to IAM role ARN (if created by the module)"
  value = try(module.eks_mod.node_groups_iam_role_arns, {})
}