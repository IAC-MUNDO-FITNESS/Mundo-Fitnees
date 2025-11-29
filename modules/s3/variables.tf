# ============================================
# Variables del Módulo S3
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}

variable "block_public_access" {
  description = "Bloquear acceso público al bucket"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Habilitar versionado en el bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
