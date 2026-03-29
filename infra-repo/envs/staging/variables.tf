variable "aws_region" {
	description = "AWS region to deploy into"
	type        = string
}

variable "cluster_name" {
	description = "EKS cluster name"
	type        = string
}

variable "kubernetes_version" {
	description = "Kubernetes version for EKS cluster"
	type        = string
	default     = "1.30"
}

variable "vpc_cidr" {
	description = "VPC CIDR block"
	type        = string
}

variable "tags" {
	description = "Common tags applied to resources"
	type        = map(string)
	default = {
		Project = "gitops-platform"
		Owner   = "devops"
	}
}
