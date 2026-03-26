variable "aws_region" {
  description = "AWS region to create the backend resources in"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name to create for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name to create for Terraform state locks"
  type        = string
}

variable "tags" {
  description = "Tags applied to the created resources"
  type        = map(string)
  default = {
    Project = "gitops-platform"
    Owner   = "devops"
  }
}
