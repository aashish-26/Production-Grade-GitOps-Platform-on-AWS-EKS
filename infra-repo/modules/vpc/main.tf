module "vpc_mod" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "gitops-vpc"
  cidr = var.cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = [cidrsubnet(var.cidr, 8, 1), cidrsubnet(var.cidr, 8, 2), cidrsubnet(var.cidr, 8, 3)]
  private_subnets = [cidrsubnet(var.cidr, 8, 11), cidrsubnet(var.cidr, 8, 12), cidrsubnet(var.cidr, 8, 13)]

  map_public_ip_on_launch = true

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(var.tags, { Terraform = "true" })
}

data "aws_availability_zones" "available" {}
