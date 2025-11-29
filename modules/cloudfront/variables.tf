# ============================================
# Variables del Módulo CloudFront
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "s3_bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN del bucket S3"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "Domain name del bucket S3"
  type        = string
}

variable "web_acl_arn" {
  description = "ARN del WAF Web ACL (opcional)"
  type        = string
  default     = ""
}

variable "price_class" {
  description = "Clase de precio de CloudFront"
  type        = string
  default     = "PriceClass_100" # USA, Canada, Europe
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
