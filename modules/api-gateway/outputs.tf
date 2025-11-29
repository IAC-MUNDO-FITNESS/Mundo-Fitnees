# ============================================
# Outputs del Módulo API Gateway
# ============================================

output "api_id" {
  description = "ID del API Gateway"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "Endpoint del API Gateway"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_execution_arn" {
  description = "Execution ARN del API Gateway"
  value       = aws_apigatewayv2_api.main.execution_arn
}

output "stage_name" {
  description = "Nombre del stage"
  value       = aws_apigatewayv2_stage.main.name
}

output "full_url" {
  description = "URL completa del API con stage"
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/${var.environment}"
}

output "endpoints" {
  description = "Endpoints de la API para testing"
  value = {
    subscription = "${aws_apigatewayv2_api.main.api_endpoint}/${var.environment}/subscription"
    access       = "${aws_apigatewayv2_api.main.api_endpoint}/${var.environment}/access"
    notification = "${aws_apigatewayv2_api.main.api_endpoint}/${var.environment}/notification"
  }
}
