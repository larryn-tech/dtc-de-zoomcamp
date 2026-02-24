# Terraform with AWS

After running into some issues with GCP, I decided to take a quick detour from the course to learn Terraform using AWS by following the [Terraform Course](https://github.com/sidpalas/devops-directive-terraform-course) by Sid from DevOps Directive.


## Getting Started

### Install Terraform (Homebrew on macOS)

```shell
brew install terraform
```
### Create AWS user and assign permissions*
1. Create non-root AWS user
2. Create user group and select policies to attach to group
    - AmazonDynamoDBFullAccess
    - AmazonEC2FullAccess
    - AmazonRDSFullAccess
    - AmazonRoute53FullAccess
    - AmazonS3FullAccess
    - IAMFullAccess
3. Save Access key + secret key for configuring AWS CLI

### Install and configure AWS CLI v2 (macOS)

1. Install AWS CLI v2 
```shell
curl "https://awscli.amazonaws.com/AWSCLIV2-2.0.30.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```
2. Configure AWS CLI
```shell
aws configure
```
- When prompted, enter the access key and secret access key from the created non-root AWS user, along with default region and output format. For example:
```shell
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-west-2
Default output format [None]: json
```

## Terraform Overview
In this section (`02-terraform-overview`), we will use Terraform to provision an EC2 instance on AWS.

### Create configuration files
In a new directory (ex. `02-terraform-overview`), we'll write our configuration files. 

The `terraform {}` block within the `terraform.tf` file configures Terraform and specifies that we are using AWS as a provider.

```hcl
# terraform.tf

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

The `provider {}` block within the `main.tf` file configures our provider settings. In this case, we set the region that AWS should create the resources in. 

The `resource {}` block outlines the components we want to include in the infrastructure. 

```hcl
# main.tf

provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-072028e29f8a73b88"
  instance_type = "t3.micro"                    # AWS Free Tier eligible

  tags = {
    Name = "learn-terraform"
  }
}
```
- We declare the resource type (`aws_instance`) and resource name (`example`), which will form the unique resource address for the resource in our configuration.
- The `ami` argument specifies which machine image to use.
- The `instance_type` argument specifies the configuration of the virtual server. 
- The  `tags` argument sets the EC2 instance's name

We can ensure that the configuration files are properly formatted according to HashiCorp's recommended style by running the following command in the terminal:

```shell
terraform fmt
```

Any modified files will be printed in the terminal.

### Create infrastructure

To begin, we must initialize our Terraform workspace. While in the working directory (ex. `02-terraform-overview`), enter the following command in the terminal:
```shell
terraform init
```
Terraform will download and install the providers defined in the configuration files into the current directory.

The configuration can be validated with the following command:
```shell
terraform validate
```

With `terraform apply`, Terraform will create an execution plan for making changes to the infrastructure.

```shell
terraform apply
```

You will be able to review the plan and confirm the changes before they are applied. Once you approve the changes by entering `yes`, Terraform will perform the actions.

Once completed, we'll see the following message in the terminal:

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

After applying the configuration, we'll see that Terraform created a `terraform.tfstate` file in the current directory. The state file keeps a snapshot of the current infrastructure and compares it to the configuration files to determine what changes are needed to reach the desired state. 

By default, the state file is stored locally. Because it can contain sensitive information, such as passwords or security keys, the state file should be stored securely. In addition, add `*.tfstate` and `.terraform/` to your `.gitignore`.

We can view our new EC2 instance by navigating to the EC2 console in AWS (make sure that the region matches the one set in the configuration file). We can also list the resources in the Terraform workspace's state with:

```shell
terraform state list
```
### Destroy infrastructure
To avoid unexpected AWS costs, always destroy the resources when finished:

```shell
terraform destroy
```

Enter `yes` to confirm Terraform's plan to destroy all resources. When we return to the EC2 console, we should see that the instance is no longer running and is terminated.

## Basic Terraform Usage

As previously mentioned, the state file is stored locally by default. While this may be suitable for personal projects, the recommended approach for team environments and production workloads is to store it remotely. Using a remote backend (ex. Terraform Cloud or AWS S3) to store state files allows us to encrypt sensitive data, collaborate with other engineers, and automate infrastructure deployment.

Christiana Shedrack has a helpful article called [Managing Terraform State with AWS S3 and Native Locking](https://medium.com/@christianashedrack/managing-terraform-state-with-aws-s3-remote-backend-a-complete-guide-3fcd8c22adef) that provides additional information on how Terraform state management works, as well as a walkthrough for setting up a remote backend with AWS S3.

In this section (`03-basic-usage`), we'll setup a remote backend using AWS S3 to store our state files.

The following steps will involve making changes to the configuration files. You can use the `config-files.md` [file](./03-basic-usage/config-files.md) to check that your files are matching at each step or copy and paste.

### Provision S3 bucket
In a new directory (ex. `03-basic-usage`), we will create new configuration files.

To create an AWS S3 bucket, we'll add the following resources to our `main.tf` file:

```hcl
# main.tf

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

- This provisions a S3 bucket that can delete all objects so that the bucket can be destroyed without error (not recommended outside of this learning project). 
- We also enable versioning on the bucket, which preserves old versions of each object so that they can be recovered in the event of accidental overwrites or deletions.
- Finally, we secure our data with AES-256 encryption.

> Note: The course mentions provisioning a DynamoDB table as well, which would be used to lock the state file. Doing so allows only one person to modify the state file at a time, which helps avoid conflicts. With Terraform 1.10+, however, S3 now has built-in locking. Therefore, DynamoDB is not needed for this project.

Our `terraform.tf` file should be the same one as from the Terraform Overview section.

```hcl
# terraform.tf

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

Provision the S3 bucket by running the following commands:
1. `terraform init`
2. `terraform plan`
3. `terraform apply`

### AWS remote backend

We'll update the `terraform.tf` file to include `backend {}` block within the `terraform block`:

```hcl
# terraform.tf

terraform {
  required_providers {
    [...]
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
- We specify the S3 bucket that we want to use for the remote backend
- We enable S3 state locking
- We enable server-side encryption of the state and lock files

When we rerun `terraform init`, Terraform will recognize that we are no longer using a local backend and have configured a remote one:

```
Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.
  ```

Enter `yes` to copy the state file to the S3 bucket.

When we navigate to the S3 console, we should see a `terraform.tf` object within our bucket.
