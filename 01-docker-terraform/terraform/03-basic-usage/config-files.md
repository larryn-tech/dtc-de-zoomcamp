# Configuration Files

## Step 1 - Provision S3 Bucket
Use following configuration files to provision S3 bucket with local state.

### `main.tff`
```hcl
provider "aws" {
  region = "us-west-1"
}


resource "aws_s3_bucket" "ln_tf_state" {
  bucket        = "ln-tfbackend-bucket" # REPLACE (bucket names must be globally unique)
  force_destroy = true
}


resource "aws_s3_bucket_versioning" "ln_tf_bucket_versioning" {
  bucket = aws_s3_bucket.ln_tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "ln_tf_state_crypto_conf" {
  bucket = aws_s3_bucket.ln_tf_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```
### `terraform.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}
```

After updating the files, run:
- `terraform init`
- `terraform plan`
- `terraform apply`

## Step 2 - AWS Remote Backend
Update `terraform.tf` file to use S3 for remote backend (init).

### `terraform.tf`
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  backend "s3" {
    bucket       = "ln-tfbackend-bucket"
    key          = "tf-infra/terraform.tfstate"
    region       = "us-west-1"
    use_lockfile = true
    encrypt      = true
  }

  required_version = ">= 1.2"
}
```

After updating the file, run:
- `terraform init`