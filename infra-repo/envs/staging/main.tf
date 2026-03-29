// Staging environment Terraform root
// Keeps module wiring consistent with dev for safe promotion.

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

module "vpc" {
  source = "../../modules/vpc"

  cidr = var.vpc_cidr
  tags = var.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  tags = var.tags
}

module "ecr" {
  source = "../../modules/ecr"
  repositories = ["api-service", "worker-service"]
  tags         = var.tags
}

module "sqs" {
  source = "../../modules/sqs"
  name = "jobs-queue"
  tags = var.tags
}
