// Prod environment Terraform root (stub). Use strict review before applying.

terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"
  cidr       = var.vpc_cidr
  aws_region = var.aws_region
  tags       = var.tags
}

module "eks" {
  source = "../../modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  aws_region   = var.aws_region
  tags         = var.tags
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
