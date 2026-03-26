// Remote backend configuration for dev environment.
// Replace TODOs or run `terraform init -backend-config=...` with real values.

terraform {
  backend "s3" {
    bucket         = "aashish-terraform-state-bucket"
    key            = "envs/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
