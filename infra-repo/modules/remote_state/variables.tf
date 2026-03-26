variable "bucket_name" {
  description = "Name of the S3 bucket to hold terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table to use for state locking"
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources"
  type        = map(string)
  default = {}
}
