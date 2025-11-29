# ============================================
# Variables - Módulo CloudWatch
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}

# ============================================
# Lambda Functions Names
# ============================================

variable "subscription_control_function_name" {
  description = "Nombre de la función Lambda Subscription Control"
  type        = string
}

variable "access_control_function_name" {
  description = "Nombre de la función Lambda Access Control"
  type        = string
}

variable "notification_service_function_name" {
  description = "Nombre de la función Lambda Notification Service"
  type        = string
}

# ============================================
# Log Retention
# ============================================

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch (0 = infinito, recomendado: 7, 14, 30, 90)"
  type        = number
  default     = 30

  validation {
    condition = contains([
      0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "log_retention_days debe ser uno de los valores permitidos por AWS"
  }
}

# ============================================
# Encryption
# ============================================

variable "enable_encryption" {
  description = "Habilitar encriptación KMS para los logs"
  type        = bool
  default     = false
}

# ============================================
# Monitoring Features
# ============================================

variable "create_metric_filters" {
  description = "Crear filtros de métricas personalizadas"
  type        = bool
  default     = true
}

variable "create_alarms" {
  description = "Crear alarmas de CloudWatch"
  type        = bool
  default     = true
}

variable "create_saved_queries" {
  description = "Crear queries guardadas de CloudWatch Insights"
  type        = bool
  default     = true
}

variable "create_dashboard" {
  description = "Crear dashboard de CloudWatch (también usado por Grafana)"
  type        = bool
  default     = true
}

variable "sns_alarm_topic_arn" {
  description = "ARN del SNS topic para enviar alarmas (opcional)"
  type        = string
  default     = ""
}

# ============================================
# Tags
# ============================================

variable "tags" {
  description = "Tags comunes para todos los recursos CloudWatch"
  type        = map(string)
  default     = {}
}
