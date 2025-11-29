# ============================================
# OUTPUTS COMPLETOS - EL MUNDO FITNESS
# 100% Arquitectura con CloudFront y WAF
# ============================================

# ============================================
# FRONTEND (CloudFront + S3)
# ============================================

output "cloudfront_url" {
  description = "⭐ URL PRINCIPAL - Frontend accesible vía CloudFront"
  value       = module.cloudfront.cloudfront_url
}

output "cloudfront_distribution_id" {
  description = "ID de distribución CloudFront (para invalidaciones de caché)"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "Nombre de dominio de CloudFront"
  value       = module.cloudfront.domain_name
}

output "s3_frontend_bucket_name" {
  description = "Nombre del bucket S3 para frontend (origin de CloudFront)"
  value       = module.s3.bucket_name
}

# ============================================
# BACKEND API (API Gateway + Lambda)
# ============================================

output "api_gateway_url" {
  description = "⭐ URL BASE de la API HTTP"
  value       = module.api_gateway.full_url
}

output "api_gateway_id" {
  description = "ID del API Gateway"
  value       = module.api_gateway.api_id
}

output "api_endpoints" {
  description = "📍 Endpoints completos de la API"
  value       = module.api_gateway.endpoints
}

# ============================================
# AUTENTICACIÓN (Cognito)
# ============================================

output "cognito_user_pool_id" {
  description = "🔐 ID del User Pool de Cognito"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "🔑 ID del cliente de Cognito (para frontend)"
  value       = module.cognito.client_id
  sensitive   = true
}

output "cognito_domain_url" {
  description = "URL del dominio de Cognito (para login/logout)"
  value       = module.cognito.domain_url
}

# ============================================
# BASE DE DATOS (DynamoDB)
# ============================================

output "dynamodb_tables" {
  description = "📊 Tablas DynamoDB creadas"
  value = {
    usuarios             = module.dynamodb.usuarios_table_name
    pagos                = module.dynamodb.pagos_table_name
    historial_asistencia = module.dynamodb.historial_table_name
  }
}

output "dynamodb_usuarios_table" {
  description = "Tabla de Usuarios"
  value       = module.dynamodb.usuarios_table_name
}

output "dynamodb_pagos_table" {
  description = "Tabla de Pagos"
  value       = module.dynamodb.pagos_table_name
}

output "dynamodb_historial_table" {
  description = "Tabla de Historial de Asistencia"
  value       = module.dynamodb.historial_table_name
}

# ============================================
# RED (VPC + NAT + Subnets)
# ============================================

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID de la subnet pública (NAT Gateway)"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID de la subnet privada (Lambdas)"
  value       = module.vpc.private_subnet_id
}

output "nat_gateway_ip" {
  description = "💰 IP pública del NAT Gateway (costo ~$32-45/mes)"
  value       = module.vpc.nat_gateway_ip
}

# ============================================
# FUNCIONES LAMBDA
# ============================================

output "lambda_functions" {
  description = "ARNs de las funciones Lambda"
  value = {
    subscription_control  = module.lambda.subscription_control_arn
    access_control        = module.lambda.access_control_arn
    notification_service  = module.lambda.notification_service_arn
  }
}

output "lambda_subscription_control_arn" {
  description = "ARN de Lambda Subscription Control (Stripe)"
  value       = module.lambda.subscription_control_arn
}

output "lambda_access_control_arn" {
  description = "ARN de Lambda Access Control (DynamoDB)"
  value       = module.lambda.access_control_arn
}

output "lambda_notification_service_arn" {
  description = "ARN de Lambda Notification Service (SES/Gmail)"
  value       = module.lambda.notification_service_arn
}

# ============================================
# SEGURIDAD (WAF)
# ============================================

output "waf_web_acl_id" {
  description = "🛡️ ID del Web ACL de WAF (protegiendo CloudFront)"
  value       = module.waf.web_acl_id
}

output "waf_web_acl_arn" {
  description = "ARN del Web ACL de WAF"
  value       = module.waf.web_acl_arn
}

# ============================================
# SES (Email Service)
# ============================================

output "ses_sender_email" {
  description = "📧 Email configurado en SES para envío de recibos"
  value       = module.ses.sender_email
}

output "ses_verification_status" {
  description = "⚠️ Instrucciones para verificar email en SES"
  value       = module.ses.verification_status
}

output "ses_configuration_set" {
  description = "Configuration Set de SES"
  value       = module.ses.configuration_set_name
}

output "ses_receipt_template" {
  description = "Nombre del template de recibos en SES"
  value       = module.ses.receipt_template_name
}

# ============================================
# CLOUDWATCH (Logs y Monitoreo)
# ============================================

output "cloudwatch_log_groups" {
  description = "📊 Log Groups de CloudWatch para Lambdas"
  value       = module.cloudwatch.all_log_group_names
}

output "cloudwatch_dashboard_url" {
  description = "🖥️ URL del CloudWatch Dashboard"
  value       = module.cloudwatch.dashboard_url
}

output "cloudwatch_log_retention" {
  description = "Días de retención de logs"
  value       = var.cloudwatch_log_retention_days
}

output "grafana_info" {
  description = "📊 Información de Grafana"
  value = {
    url               = "http://localhost:3000"
    default_user      = "admin"
    default_password  = "ElMundoFitness2024!"
    datasource_region = var.aws_region
    log_groups        = module.cloudwatch.all_log_group_names
  }
}

# ============================================
# RESUMEN COMPLETO DE LA INFRAESTRUCTURA
# ============================================

output "infrastructure_summary" {
  description = "📋 RESUMEN COMPLETO DE LA ARQUITECTURA"
  value = {
    # ===== FRONTEND =====
    frontend_url              = module.cloudfront.cloudfront_url
    cloudfront_distribution   = module.cloudfront.distribution_id
    s3_bucket                 = module.s3.bucket_name
    
    # ===== BACKEND API =====
    api_base_url              = module.api_gateway.full_url
    api_id                    = module.api_gateway.api_id
    
    # ===== AUTENTICACIÓN =====
    cognito_user_pool_id      = module.cognito.user_pool_id
    cognito_client_id         = module.cognito.client_id
    cognito_login_url         = module.cognito.domain_url
    
    # ===== BASE DE DATOS =====
    dynamodb_usuarios         = module.dynamodb.usuarios_table_name
    dynamodb_pagos            = module.dynamodb.pagos_table_name
    dynamodb_historial        = module.dynamodb.historial_table_name
    
    # ===== RED =====
    vpc_id                    = module.vpc.vpc_id
    nat_gateway_ip            = module.vpc.nat_gateway_ip
    
    # ===== SEGURIDAD =====
    waf_acl_id                = module.waf.web_acl_id
    
    # ===== EMAIL (SES) =====
    ses_sender_email          = module.ses.sender_email
    ses_configuration_set     = module.ses.configuration_set_name
    
    # ===== MONITOREO =====
    cloudwatch_log_groups     = module.cloudwatch.all_log_group_names
    cloudwatch_dashboard      = module.cloudwatch.dashboard_url
    grafana_url               = "http://localhost:3000"
    
    # ===== CONFIGURACIÓN =====
    region                    = var.aws_region
    environment               = var.environment
    project                   = var.project_name
  }
}

# ============================================
# DEPLOYMENT NOTES (Visible en outputs)
# ============================================

output "deployment_instructions" {
  description = "📝 Instrucciones de despliegue"
  value = <<-EOT
  
  ╔════════════════════════════════════════════════════════════╗
  ║   INFRAESTRUCTURA DESPLEGADA - EL MUNDO FITNESS           ║
  ╚════════════════════════════════════════════════════════════╝
  
  ✅ FRONTEND:
     URL: ${module.cloudfront.cloudfront_url}
     CloudFront ID: ${module.cloudfront.distribution_id}
     S3 Bucket: ${module.s3.bucket_name}
  
  ✅ API BACKEND:
     Base URL: ${module.api_gateway.full_url}
     
  ✅ AUTENTICACIÓN:
     User Pool: ${module.cognito.user_pool_id}
     Client ID: ${module.cognito.client_id}
  
  ✅ BASE DE DATOS:
     - Usuarios: ${module.dynamodb.usuarios_table_name}
     - Pagos: ${module.dynamodb.pagos_table_name}
     - Historial: ${module.dynamodb.historial_table_name}
  
  📌 PRÓXIMOS PASOS:
  
  1. Subir archivos del frontend a S3:
     aws s3 sync ./build s3://${module.s3.bucket_name}/ --delete
  
  2. Invalidar caché de CloudFront:
     aws cloudfront create-invalidation \
       --distribution-id ${module.cloudfront.distribution_id} \
       --paths "/*"
  
  3. Configurar variables de entorno en el frontend:
     REACT_APP_API_URL=${module.api_gateway.full_url}
     REACT_APP_COGNITO_USER_POOL_ID=${module.cognito.user_pool_id}
     REACT_APP_COGNITO_CLIENT_ID=${module.cognito.client_id}
  
  4. Actualizar código Lambda (crear ZIP y subir):
     cd lambda-functions
     zip -r function.zip .
     aws lambda update-function-code \
       --function-name <lambda-name> \
       --zip-file fileb://function.zip
  
  💰 COSTOS ESTIMADOS (us-east-1):
     - NAT Gateway: ~$32-45/mes + data transfer
     - Lambda: Pay-per-use (primeros 1M requests gratis)
     - DynamoDB: On-demand pricing
     - API Gateway: Primeros 1M gratis/mes
     - CloudFront: Primeros 1TB gratis/mes (12 meses)
     - S3: Storage + requests
     - Cognito: Primeros 50K MAU gratis
     - WAF: ~$5/mes + rules
  
  🔐 SEGURIDAD:
     ✓ WAF protegiendo CloudFront
     ✓ Cognito JWT Authorizer en API Gateway
     ✓ Lambdas en subnet privada
     ✓ VPC Endpoints para DynamoDB y S3
     ✓ S3 con acceso vía OAC (no público)
  
  EOT
}
