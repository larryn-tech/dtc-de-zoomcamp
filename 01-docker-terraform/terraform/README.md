# Terraform with AWS

After running into some issues with GCP, I decided to take a quick detour from the course to learn Terraform using AWS by following the [Terraform Course](https://github.com/sidpalas/devops-directive-terraform-course) by DevOps Directive.


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

## Basic Infrastructure Setup
In this section, we use Terraform to provision an EC2 instance on AWS.

### Create configuration files
In a new directory (ex. `02-basic-setup`), we'll write our configuration files. 

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

To begin, we must initialize our Terraform workspace. While in the working directory (ex. `02-basic-setup`), enter the following command in the terminal:
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