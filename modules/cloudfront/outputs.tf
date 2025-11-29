# ============================================
# Outputs del Módulo CloudFront
# ============================================

output "distribution_id" {
  description = "ID de la distribución CloudFront"
  value       = aws_cloudfront_distribution.main.id
}

output "distribution_arn" {
  description = "ARN de la distribución CloudFront"
  value       = aws_cloudfront_distribution.main.arn
}

output "domain_name" {
  description = "Domain name de CloudFront"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_url" {
  description = "URL completa de CloudFront"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}

output "hosted_zone_id" {
  description = "Hosted Zone ID de CloudFront"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}
