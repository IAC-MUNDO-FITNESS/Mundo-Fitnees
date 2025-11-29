# ============================================
# Outputs del Módulo Lambda
# ============================================

output "subscription_control_function_name" {
  description = "Nombre de la función Lambda Subscription Control"
  value       = aws_lambda_function.subscription_control.function_name
}

output "subscription_control_arn" {
  description = "ARN de Lambda Subscription Control"
  value       = aws_lambda_function.subscription_control.arn
}

output "subscription_control_invoke_arn" {
  description = "Invoke ARN de Lambda Subscription Control"
  value       = aws_lambda_function.subscription_control.invoke_arn
}

output "access_control_function_name" {
  description = "Nombre de la función Lambda Access Control"
  value       = aws_lambda_function.access_control.function_name
}

output "access_control_arn" {
  description = "ARN de Lambda Access Control"
  value       = aws_lambda_function.access_control.arn
}

output "access_control_invoke_arn" {
  description = "Invoke ARN de Lambda Access Control"
  value       = aws_lambda_function.access_control.invoke_arn
}

output "notification_service_function_name" {
  description = "Nombre de la función Lambda Notification Service"
  value       = aws_lambda_function.notification_service.function_name
}

output "notification_service_arn" {
  description = "ARN de Lambda Notification Service"
  value       = aws_lambda_function.notification_service.arn
}

output "notification_service_invoke_arn" {
  description = "Invoke ARN de Lambda Notification Service"
  value       = aws_lambda_function.notification_service.invoke_arn
}

output "lambda_security_group_id" {
  description = "ID del Security Group de las Lambdas"
  value       = aws_security_group.lambda.id
}

output "lambda_execution_role_arn" {
  description = "ARN del rol de ejecución de Lambda"
  value       = aws_iam_role.lambda_execution.arn
}
