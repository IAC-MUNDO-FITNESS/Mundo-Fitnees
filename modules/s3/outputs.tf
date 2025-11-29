# ============================================
# Outputs del Módulo S3
# ============================================

output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.frontend.arn
}

output "bucket_domain_name" {
  description = "Domain name del bucket"
  value       = aws_s3_bucket.frontend.bucket_domain_name
}

output "website_endpoint" {
  description = "Endpoint del website S3"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}
