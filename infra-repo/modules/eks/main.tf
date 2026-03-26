module "eks_mod" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  endpoint_public_access  = true
  endpoint_private_access = true

  addons = {
    vpc-cni = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"

      tags = merge(var.tags, { role = "worker" })
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = var.tags
}
