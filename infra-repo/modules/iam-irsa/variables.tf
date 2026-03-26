variable "name_prefix" {
  description = "Prefix for IAM role name"
  type        = string
}

variable "service_account_namespace" {
  description = "Kubernetes namespace of the service account that will assume this role"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name that will assume this role"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider to use for the role's trust relationship (e.g. from aws_iam_openid_connect_provider)"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL (used to form the sub claim key), e.g. https://oidc.eks.<region>.amazonaws.com/id/<id>"
  type        = string
}

variable "policy_arns" {
  description = "List of managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Optional inline policy JSON string to attach to the role"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to created IAM resources"
  type        = map(string)
  default     = {}
}
