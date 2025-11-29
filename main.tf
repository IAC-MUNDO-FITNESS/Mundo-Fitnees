# ============================================
# INFRAESTRUCTURA COMPLETA - EL MUNDO FITNESS
# Arquitectura AWS Serverless con VPC Privada
# 100% del Diagrama Implementado
# ============================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider principal para recursos en us-east-1
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# Provider adicional para WAF (debe estar en us-east-1 para CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = var.common_tags
  }
}

# ============================================
# DATA SOURCES
# ============================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ============================================
# 1. MÓDULO VPC (Networking)
# ============================================

module "vpc" {
  source = "./modules/vpc"

  project_name        = "${var.project_name}-${var.environment}"
  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  tags                = var.common_tags
}

# ============================================
# 2. MÓDULO DYNAMODB (Base de Datos)
# ============================================

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = "${var.project_name}-${var.environment}"
  billing_mode = var.dynamodb_billing_mode
  tags         = var.common_tags
}

# ============================================
# 3. MÓDULO S3 (Almacenamiento Frontend)
# ============================================

module "s3" {
  source = "./modules/s3"

  project_name        = "${var.project_name}-${var.environment}"
  account_id          = data.aws_caller_identity.current.account_id
  block_public_access = true
  enable_versioning   = true
  tags                = var.common_tags
}

# ============================================
# 4. MÓDULO WAF (Seguridad Web)
# Nota: WAF para CloudFront DEBE crearse en us-east-1
# ============================================

module "waf" {
  source = "./modules/waf"
  providers = {
    aws = aws.us_east_1
  }

  project_name  = "${var.project_name}-${var.environment}"
  rate_limit    = 2000
  enable_logging = false
  tags          = var.common_tags
}

# ============================================
# 5. MÓDULO CLOUDFRONT (CDN + Frontend)
# ============================================

module "cloudfront" {
  source = "./modules/cloudfront"

  project_name           = "${var.project_name}-${var.environment}"
  s3_bucket_name         = module.s3.bucket_name
  s3_bucket_arn          = module.s3.bucket_arn
  s3_bucket_domain_name  = module.s3.bucket_domain_name
  web_acl_arn            = module.waf.web_acl_arn
  price_class            = "PriceClass_100"
  tags                   = var.common_tags

  depends_on = [module.s3, module.waf]
}

# ============================================
# 6. MÓDULO COGNITO (Autenticación)
# ============================================

module "cognito" {
  source = "./modules/cognito"

  project_name = "${var.project_name}-${var.environment}"
  account_id   = data.aws_caller_identity.current.account_id
  
  # Configuración de seguridad de contraseñas
  password_minimum_length    = 8
  password_require_lowercase = true
  password_require_numbers   = true
  password_require_symbols   = true
  password_require_uppercase = true
  
  # URLs de callback (actualizar con tu dominio de CloudFront)
  callback_urls = [
    "http://localhost:3000/callback",
    "https://${module.cloudfront.domain_name}/callback"
  ]
  logout_urls = [
    "http://localhost:3000/logout",
    "https://${module.cloudfront.domain_name}/logout"
  ]
  
  tags = var.common_tags

  depends_on = [module.cloudfront]
}

# ============================================
# 7. MÓDULO SES (Email Service)
# ============================================

module "ses" {
  source = "./modules/ses"

  project_name              = "${var.project_name}-${var.environment}"
  aws_region                = var.aws_region
  account_id                = data.aws_caller_identity.current.account_id
  sender_email              = var.ses_sender_email
  domain                    = var.ses_domain
  enable_notifications      = true
  create_receipt_template   = true
  create_notification_template = true
  tags                      = var.common_tags
}

# ============================================
# 8. MÓDULO CLOUDWATCH (Logs y Monitoreo)
# ============================================

module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name                        = "${var.project_name}-${var.environment}"
  environment                         = var.environment
  aws_region                          = var.aws_region
  account_id                          = data.aws_caller_identity.current.account_id
  
  # Nombres de las funciones Lambda (deben coincidir con los creados por el módulo Lambda)
  subscription_control_function_name  = "${var.project_name}-${var.environment}-subscription-control"
  access_control_function_name        = "${var.project_name}-${var.environment}-access-control"
  notification_service_function_name  = "${var.project_name}-${var.environment}-notification-service"
  
  # Configuración de retención de logs
  log_retention_days                  = var.cloudwatch_log_retention_days
  enable_encryption                   = false
  
  # Features de monitoreo
  create_metric_filters               = true
  create_alarms                       = true
  create_saved_queries                = true
  create_dashboard                    = true
  sns_alarm_topic_arn                 = ""
  
  tags = var.common_tags
}

# ============================================
# 9. MÓDULO LAMBDA (Funciones Serverless)
# ============================================

# ============================================
# 9. MÓDULO LAMBDA (Funciones Serverless)
# ============================================

module "lambda" {
  source = "./modules/lambda"

  project_name          = "${var.project_name}-${var.environment}"
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_id     = module.vpc.private_subnet_id
  usuarios_table_name   = module.dynamodb.usuarios_table_name
  historial_table_name  = module.dynamodb.historial_table_name
  dynamodb_table_arns   = module.dynamodb.all_table_arns
  lambda_runtime        = var.lambda_runtime
  lambda_memory_size    = var.lambda_memory_size
  lambda_timeout        = var.lambda_timeout
  
  # CloudWatch Logs Integration
  cloudwatch_policy_arn    = module.cloudwatch.lambda_cloudwatch_policy_arn
  cloudwatch_log_group_arns = module.cloudwatch.all_log_group_arns
  
  # SES Integration
  ses_policy_arn          = module.ses.ses_policy_arn
  ses_sender_email        = module.ses.sender_email
  ses_configuration_set   = module.ses.configuration_set_name
  
  tags                  = var.common_tags

  depends_on = [
    module.vpc,
    module.dynamodb,
    module.cloudwatch,
    module.ses
  ]
}

# ============================================
# 10. MÓDULO API GATEWAY (API HTTP + Integración)
# ============================================

module "api_gateway" {
  source = "./modules/api-gateway"

  project_name                        = "${var.project_name}-${var.environment}"
  environment                         = var.environment
  
  # Lambdas
  subscription_control_function_name  = module.lambda.subscription_control_function_name
  subscription_control_invoke_arn     = module.lambda.subscription_control_invoke_arn
  access_control_function_name        = module.lambda.access_control_function_name
  access_control_invoke_arn           = module.lambda.access_control_invoke_arn
  notification_service_function_name  = module.lambda.notification_service_function_name
  notification_service_invoke_arn     = module.lambda.notification_service_invoke_arn
  
  # Cognito Authorizer
  cognito_user_pool_client_id         = module.cognito.client_id
  cognito_user_pool_endpoint          = module.cognito.user_pool_endpoint
  
  # CORS Configuration
  cors_allow_origins = [
    "http://localhost:3000",
    "https://${module.cloudfront.domain_name}"
  ]
  
  tags = var.common_tags

  depends_on = [
    module.lambda,
    module.cognito,
    module.cloudfront
  ]
}

# ============================================
# NOTA: Los outputs están definidos en outputs.tf
# No duplicar aquí para evitar conflictos
# ============================================
