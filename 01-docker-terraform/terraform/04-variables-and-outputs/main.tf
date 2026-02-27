provider "aws" {
  region = var.region
}

# VPC

resource "aws_vpc" "ln_vpc" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "ln_subnet_a" {
  vpc_id            = aws_vpc.ln_vpc.id
  cidr_block        = var.subnet_cidrs[0]
  availability_zone = var.azs[0]
}

resource "aws_subnet" "ln_subnet_b" {
  vpc_id            = aws_vpc.ln_vpc.id
  cidr_block        = var.subnet_cidrs[1]
  availability_zone = var.azs[1]
}

resource "aws_db_subnet_group" "ln_default" {
  name        = "main_subnet_group"
  subnet_ids  = [aws_subnet.ln_subnet_a.id, aws_subnet.ln_subnet_b.id]
  description = "A subnet group for RDS instance"
}

resource "aws_security_group" "ln_rds_sg" {
  name_prefix = "rds-"
  vpc_id      = aws_vpc.ln_vpc.id

  # Add any additional ingress/egress rules as needed
  ingress {
    from_port   = var.db_sg_port
    to_port     = var.db_sg_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}

# S3 - TF State

resource "aws_s3_bucket" "ln_tf_state" {
  bucket        = var.tf_state_bucket
  force_destroy = true
}


resource "aws_s3_bucket_versioning" "ln_tf_bucket_versioning" {
  bucket = aws_s3_bucket.ln_tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "ln_tf_state_crypto_conf" {
  bucket = aws_s3_bucket.ln_tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 - Logs

resource "aws_s3_bucket" "ln_log" {
  bucket_prefix = var.bucket_prefix
  force_destroy = true
}


resource "aws_s3_bucket_versioning" "ln_data_bucket_versioning" {
  bucket = aws_s3_bucket.ln_log.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "ln_data_crypto_conf" {
  bucket = aws_s3_bucket.ln_log.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# RDS

resource "aws_db_instance" "db_instance" {
  allocated_storage      = 20
  storage_type           = "standard"
  engine                 = "postgres"
  engine_version         = "12"
  instance_class         = "db.t3.micro"
  username               = var.db_user
  password               = var.db_pass
  db_subnet_group_name   = aws_db_subnet_group.ln_default.name
  vpc_security_group_ids = [aws_security_group.ln_rds_sg.id]
  skip_final_snapshot    = true
}