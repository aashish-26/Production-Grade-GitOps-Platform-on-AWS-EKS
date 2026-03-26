Bootstrap remote state (S3 + DynamoDB)

Purpose
- Create the S3 bucket for storing Terraform state and the DynamoDB table used for state locking.

Important: This must be run once before you `terraform init` in each environment, unless you already have a bucket and lock table.

Steps (recommended)
1. Edit `bootstrap/remote-state/terraform.tfvars` and set:
   - `aws_region` (e.g. us-east-1)
   - `bucket_name` (must be globally unique)
   - `lock_table_name` (unique per account/region)

2. Run bootstrap (this uses local state to create the remote backend):

```bash
cd infra-repo/bootstrap/remote-state
terraform init
terraform apply -var-file=terraform.tfvars
```

3. Note outputs: `bucket_name` and `lock_table_name`.

4. Configure each environment backend (you can either edit `envs/*/backend.tf` files or run `terraform init -backend-config=...`):

Example using CLI to pass backend-config:

```bash
cd infra-repo/envs/dev
terraform init \
  -backend-config="bucket=<BUCKET_NAME>" \
  -backend-config="key=envs/dev/terraform.tfstate" \
  -backend-config="region=<REGION>" \
  -backend-config="dynamodb_table=<LOCK_TABLE_NAME>"

terraform plan
```

Notes
- You can also provide an S3 bucket and DynamoDB table that were created by other tooling. Just supply their names in the backend-config parameters.
- For automation, store these values in CI secrets or use a secure parameter store.

Security
- The S3 bucket is created with server-side encryption and public access blocked.
- DynamoDB is created with pay-per-request billing to avoid capacity management for lock usage.

# TODO: USER_ACTION_REQUIRED
- Set `terraform.tfvars` values in `bootstrap/remote-state` before running the bootstrap.
- After creating the backend, update or init each env with the backend config.
