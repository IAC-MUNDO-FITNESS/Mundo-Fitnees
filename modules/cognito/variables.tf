# ============================================
# Variables del Módulo Cognito
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}

variable "password_minimum_length" {
  description = "Longitud mínima de la contraseña"
  type        = number
  default     = 8
}

variable "password_require_lowercase" {
  description = "Requerir minúsculas en la contraseña"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Requerir números en la contraseña"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Requerir símbolos en la contraseña"
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Requerir mayúsculas en la contraseña"
  type        = bool
  default     = true
}

variable "mfa_configuration" {
  description = "Configuración de MFA (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OFF"
}

variable "callback_urls" {
  description = "URLs de callback para Cognito"
  type        = list(string)
  default     = ["http://localhost:3000/callback"]
}

variable "logout_urls" {
  description = "URLs de logout para Cognito"
  type        = list(string)
  default     = ["http://localhost:3000/logout"]
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
