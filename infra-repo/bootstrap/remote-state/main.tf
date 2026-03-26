// Bootstrap root to create remote state S3 bucket and DynamoDB lock table
// NOTE: This should be run once manually (local state) to create the remote backend resources.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" {
  region = var.aws_region
}

module "remote_state" {
  source          = "../../modules/remote_state"
  bucket_name     = var.bucket_name
  lock_table_name = var.lock_table_name
  tags            = var.tags
}

output "bucket_name" { value = module.remote_state.bucket_name }
output "lock_table_name" { value = module.remote_state.lock_table_name }
