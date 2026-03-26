// Remote state resources: S3 bucket for tfstate and DynamoDB table for state locking
// This module creates an encrypted, versioned S3 bucket and a DynamoDB table for locking.

resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  force_destroy = false

  tags = merge(var.tags, { Name = var.bucket_name })
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, { Name = var.lock_table_name })
}

output "bucket_name" {
  value = aws_s3_bucket.tfstate.id
}

output "lock_table_name" {
  value = aws_dynamodb_table.locks.name
}
