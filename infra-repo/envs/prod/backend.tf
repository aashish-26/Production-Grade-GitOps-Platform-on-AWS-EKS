// Remote backend configuration for prod environment.
// Replace TODOs or run `terraform init -backend-config=...` with real values.

terraform {
  backend "s3" {
    bucket         = "# TODO: replace-with-remote-state-bucket"
    key            = "envs/prod/terraform.tfstate"
    region         = "# TODO: replace-with-region"
    dynamodb_table = "# TODO: replace-with-lock-table-name"
    encrypt        = true
  }
}
