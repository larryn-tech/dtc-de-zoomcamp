output "tf_bucket_id" {
  value = aws_s3_bucket.ln_tf_state.id
}

output "log_bucket_id" {
  value = aws_s3_bucket.ln_log.id
}


output "rds_endpoint" {
  description = "RDS instance hostname"
  value       = aws_db_instance.db_instance.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.db_instance.port
}