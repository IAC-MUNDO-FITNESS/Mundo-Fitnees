# ============================================
# Variables de Configuración - El Mundo Fitness
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "elmundo-fitness"
}

variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

# ============================================
# Variables de Red (VPC)
# ============================================

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block para la subnet pública"
  type        = string
  default     = "10.0.101.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block para la subnet privada (Lambdas)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Zona de disponibilidad"
  type        = string
  default     = "us-east-1a"
}

# ============================================
# Variables de Lambda
# ============================================

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

# ============================================
# Variables de DynamoDB
# ============================================

variable "dynamodb_billing_mode" {
  description = "Modo de billing para DynamoDB"
  type        = string
  default     = "PAY_PER_REQUEST"
}

# ============================================
# Variables de SES
# ============================================

variable "ses_sender_email" {
  description = "Email address validado en SES para enviar recibos"
  type        = string
  default     = "francoalessandro0306@gmail.com"
}

variable "ses_domain" {
  description = "Dominio para configurar DKIM en SES (opcional)"
  type        = string
  default     = ""
}

# ============================================
# Variables de CloudWatch
# ============================================

variable "cloudwatch_log_retention_days" {
  description = "Días de retención de logs en CloudWatch (7, 14, 30, 90, etc.)"
  type        = number
  default     = 30
}

# ============================================
# Tags Comunes
# ============================================

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default = {
    Project     = "ElMundoFitness"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}
