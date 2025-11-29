# ============================================
# Variables del Módulo WAF
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "rate_limit" {
  description = "Límite de peticiones por IP en 5 minutos"
  type        = number
  default     = 2000
}

variable "enable_logging" {
  description = "Habilitar logging de WAF"
  type        = bool
  default     = false
}

variable "log_destination_arn" {
  description = "ARN del destino de logs (Kinesis Firehose)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
