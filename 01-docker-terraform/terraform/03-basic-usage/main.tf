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
