# ============================================
# Outputs del Módulo Cognito
# ============================================

output "user_pool_id" {
  description = "ID del Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN del Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Endpoint del Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

output "client_id" {
  description = "ID del Cliente de Cognito"
  value       = aws_cognito_user_pool_client.main.id
}

output "client_secret" {
  description = "Secret del Cliente de Cognito"
  value       = aws_cognito_user_pool_client.main.client_secret
  sensitive   = true
}

output "domain" {
  description = "Dominio de Cognito"
  value       = aws_cognito_user_pool_domain.main.domain
}

output "domain_url" {
  description = "URL del dominio de Cognito"
  value       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

data "aws_region" "current" {}
