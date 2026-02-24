terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  # Comment out following backend block if Terraform state bucket has not been provisioned yet
  # Uncomment and rerun terraform init after
  backend "s3" {
    bucket       = "ln-tfbackend-bucket"
    key          = "tf-infra/terraform.tfstate"
    region       = "us-west-1"
    use_lockfile = true
    encrypt      = true
  }

  required_version = ">= 1.2"
}