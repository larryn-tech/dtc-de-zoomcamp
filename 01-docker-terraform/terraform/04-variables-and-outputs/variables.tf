# General Variables

variable "region" {
  description = "Default region for provider"
  type        = string
  default     = "us-west-1"
}


# VPC Variables

variable "cidr_block" {
  description = "VPC IP range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "Subnet CIDR values"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-west-1a", "us-west-1c"]
}

# EC2 Variables

variable "ami" {
  description = "Amazon machine image for EC2 instance"
  type        = string
  default     = "ami-072028e29f8a73b88"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "ln_instance"
}

# S3 Variables

variable "bucket_prefix" {
  description = "Creates unique bucket name starting with specified prefix"
  type        = string
  default     = "ln-bucket"
}

variable "tf_state_bucket" {
  description = "S3 bucket for storing Terraform state"
  type        = string
  default     = "ln-tfbackend-bucket"
}


# RDS Variables

variable "db_name" {
  description = "Name of DB"
  type        = string
}

variable "db_user" {
  description = "Username for DB"
  type        = string
}

variable "db_pass" {
  description = "Password for DB"
  type        = string
  sensitive   = true
}

variable "db_sg_port" {
  description = "DB security group port"
  type        = string
  default     = 3306
}