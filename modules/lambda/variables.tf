# ============================================
# Variables del Módulo Lambda
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "private_subnet_id" {
  description = "ID de la subnet privada"
  type        = string
}

variable "usuarios_table_name" {
  description = "Nombre de la tabla de Usuarios"
  type        = string
}

variable "historial_table_name" {
  description = "Nombre de la tabla de Historial"
  type        = string
}

variable "dynamodb_table_arns" {
  description = "Lista de ARNs de tablas DynamoDB"
  type        = list(string)
}

variable "lambda_runtime" {
  description = "Runtime de las funciones Lambda"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_memory_size" {
  description = "Memoria asignada a las Lambdas (MB)"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout de las Lambdas (segundos)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}

# ============================================
# CloudWatch Logs
# ============================================

variable "cloudwatch_policy_arn" {
  description = "ARN de la política IAM de CloudWatch Logs"
  type        = string
}

variable "cloudwatch_log_group_arns" {
  description = "Lista de ARNs de los Log Groups de CloudWatch"
  type        = list(string)
  default     = []
}

# ============================================
# Amazon SES
# ============================================

variable "ses_policy_arn" {
  description = "ARN de la política IAM de SES"
  type        = string
}

variable "ses_sender_email" {
  description = "Email configurado en SES para envío de recibos"
  type        = string
  default     = "francoalessandro0306@gmail.com"
}

variable "ses_configuration_set" {
  description = "Nombre del Configuration Set de SES"
  type        = string
  default     = ""
}
