# ============================================
# Variables - Módulo SES
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS donde se despliega SES"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}

# ============================================
# Email Configuration
# ============================================

variable "sender_email" {
  description = "Email address para enviar recibos y notificaciones (debe ser verificado en SES)"
  type        = string
  default     = "francoalessandro0306@gmail.com"
}

variable "domain" {
  description = "Dominio para configurar DKIM (opcional). Si está vacío, solo se valida el email"
  type        = string
  default     = ""
}

# ============================================
# Notifications
# ============================================

variable "enable_notifications" {
  description = "Habilitar notificaciones SNS para bounces y complaints"
  type        = bool
  default     = true
}

# ============================================
# Templates
# ============================================

variable "create_receipt_template" {
  description = "Crear template HTML para recibos de pago"
  type        = bool
  default     = true
}

variable "create_notification_template" {
  description = "Crear template HTML para notificaciones generales"
  type        = bool
  default     = true
}

# ============================================
# Tags
# ============================================

variable "tags" {
  description = "Tags comunes para todos los recursos SES"
  type        = map(string)
  default     = {}
}
