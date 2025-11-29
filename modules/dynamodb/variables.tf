# ============================================
# Variables del Módulo DynamoDB
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "billing_mode" {
  description = "Modo de billing para DynamoDB (PROVISIONED o PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
