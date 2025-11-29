# ============================================
# Variables del Módulo API Gateway
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "subscription_control_function_name" {
  description = "Nombre de la función Lambda Subscription Control"
  type        = string
}

variable "subscription_control_invoke_arn" {
  description = "Invoke ARN de Lambda Subscription Control"
  type        = string
}

variable "access_control_function_name" {
  description = "Nombre de la función Lambda Access Control"
  type        = string
}

variable "access_control_invoke_arn" {
  description = "Invoke ARN de Lambda Access Control"
  type        = string
}

variable "notification_service_function_name" {
  description = "Nombre de la función Lambda Notification Service"
  type        = string
}

variable "notification_service_invoke_arn" {
  description = "Invoke ARN de Lambda Notification Service"
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "ID del cliente de Cognito User Pool"
  type        = string
}

variable "cognito_user_pool_endpoint" {
  description = "Endpoint del Cognito User Pool"
  type        = string
}

variable "cors_allow_origins" {
  description = "Orígenes permitidos para CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "Métodos HTTP permitidos para CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "Headers permitidos para CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_max_age" {
  description = "Max age para CORS preflight"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
