// Dev Environment - Root Terraform Configuration
// Clean module wiring for GitOps platform

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

############################################
# VPC MODULE
############################################
module "vpc" {
  source = "../../modules/vpc"

  cidr = var.vpc_cidr
  tags = var.tags
}

############################################
# EKS MODULE
############################################
module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  tags = var.tags
}

############################################
# ECR MODULE
############################################
module "ecr" {
  source = "../../modules/ecr"

  repositories = [
    "api-service",
    "worker-service"
  ]

  tags = var.tags
}

############################################
# SQS MODULE
############################################
module "sqs" {
  source = "../../modules/sqs"

  name = "jobs-queue"
  tags = var.tags
}

############################################
# OUTPUTS
############################################
output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API endpoint"
}

output "ecr_repository_urls" {
  value       = module.ecr.repository_urls
  description = "ECR repo URLs"
}

output "sqs_queue_url" {
  value       = module.sqs.queue_url
  description = "SQS queue URL"
}
