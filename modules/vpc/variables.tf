# ============================================
# Variables del Módulo VPC
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block para la subnet pública"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block para la subnet privada"
  type        = string
}

variable "availability_zone" {
  description = "Zona de disponibilidad"
  type        = string
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
