// Simple ECR module: create repositories and return repository URL map

// Variables are declared in variables.tf to keep interface definitions centralized.
// This file contains only resource definitions.

resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repositories)

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  tags = merge(var.tags, { repository = each.key })
}

// Output is declared in outputs.tf
