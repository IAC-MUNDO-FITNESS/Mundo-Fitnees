# ============================================
# Outputs - Módulo CloudWatch
# ============================================

# ============================================
# Log Groups
# ============================================

output "subscription_control_log_group_name" {
  description = "Nombre del log group de Subscription Control Lambda"
  value       = aws_cloudwatch_log_group.subscription_control.name
}

output "subscription_control_log_group_arn" {
  description = "ARN del log group de Subscription Control Lambda"
  value       = aws_cloudwatch_log_group.subscription_control.arn
}

output "access_control_log_group_name" {
  description = "Nombre del log group de Access Control Lambda"
  value       = aws_cloudwatch_log_group.access_control.name
}

output "access_control_log_group_arn" {
  description = "ARN del log group de Access Control Lambda"
  value       = aws_cloudwatch_log_group.access_control.arn
}

output "notification_service_log_group_name" {
  description = "Nombre del log group de Notification Service Lambda"
  value       = aws_cloudwatch_log_group.notification_service.name
}

output "notification_service_log_group_arn" {
  description = "ARN del log group de Notification Service Lambda"
  value       = aws_cloudwatch_log_group.notification_service.arn
}

output "all_log_group_names" {
  description = "Lista de todos los nombres de log groups (útil para Grafana datasource)"
  value = [
    aws_cloudwatch_log_group.subscription_control.name,
    aws_cloudwatch_log_group.access_control.name,
    aws_cloudwatch_log_group.notification_service.name
  ]
}

output "all_log_group_arns" {
  description = "Lista de todos los ARNs de log groups"
  value = [
    aws_cloudwatch_log_group.subscription_control.arn,
    aws_cloudwatch_log_group.access_control.arn,
    aws_cloudwatch_log_group.notification_service.arn
  ]
}

# ============================================
# IAM Policy
# ============================================

output "lambda_cloudwatch_policy_arn" {
  description = "ARN de la política IAM para que Lambda escriba en CloudWatch"
  value       = aws_iam_policy.lambda_cloudwatch.arn
}

output "lambda_cloudwatch_policy_name" {
  description = "Nombre de la política IAM de CloudWatch"
  value       = aws_iam_policy.lambda_cloudwatch.name
}

# ============================================
# KMS (si está habilitado)
# ============================================

output "kms_key_id" {
  description = "ID de la KMS key para encriptar logs (si está habilitado)"
  value       = var.enable_encryption ? aws_kms_key.cloudwatch[0].id : ""
}

output "kms_key_arn" {
  description = "ARN de la KMS key para encriptar logs (si está habilitado)"
  value       = var.enable_encryption ? aws_kms_key.cloudwatch[0].arn : ""
}

# ============================================
# Dashboard
# ============================================

output "dashboard_name" {
  description = "Nombre del CloudWatch Dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_name : ""
}

output "dashboard_url" {
  description = "URL del CloudWatch Dashboard en la consola AWS"
  value = var.create_dashboard ? "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}" : ""
}

# ============================================
# Configuración para Grafana
# ============================================

output "grafana_datasource_config" {
  description = "Configuración para agregar CloudWatch como datasource en Grafana"
  value = {
    type   = "cloudwatch"
    name   = "AWS CloudWatch - ${var.project_name}"
    region = var.aws_region
    default_region = var.aws_region
    log_groups = [
      aws_cloudwatch_log_group.subscription_control.name,
      aws_cloudwatch_log_group.access_control.name,
      aws_cloudwatch_log_group.notification_service.name
    ]
    namespaces = [
      "AWS/Lambda",
      "${var.project_name}/Lambda"
    ]
  }
}

# ============================================
# Monitoring Summary
# ============================================

output "monitoring_summary" {
  description = "Resumen de la configuración de monitoreo"
  value = {
    log_retention_days    = var.log_retention_days
    encryption_enabled    = var.enable_encryption
    metric_filters_count  = var.create_metric_filters ? 3 : 0
    alarms_count          = var.create_alarms ? 2 : 0
    saved_queries_count   = var.create_saved_queries ? 3 : 0
    dashboard_created     = var.create_dashboard
    log_groups = [
      aws_cloudwatch_log_group.subscription_control.name,
      aws_cloudwatch_log_group.access_control.name,
      aws_cloudwatch_log_group.notification_service.name
    ]
  }
}

output "log_retention_info" {
  description = "Información sobre la retención de logs"
  value = <<-EOT
  
  📊 CLOUDWATCH LOGS - Configuración
  
  ✅ Log Groups Creados: 3
     - ${aws_cloudwatch_log_group.subscription_control.name}
     - ${aws_cloudwatch_log_group.access_control.name}
     - ${aws_cloudwatch_log_group.notification_service.name}
  
  ⏱️  Retención: ${var.log_retention_days} días
     ${var.log_retention_days == 0 ? "⚠️  Los logs se guardarán INFINITAMENTE (puede generar costos altos)" : "✅ Los logs se eliminarán automáticamente después de ${var.log_retention_days} días"}
  
  🔐 Encriptación: ${var.enable_encryption ? "✅ Habilitada con KMS" : "❌ Deshabilitada (datos en texto plano)"}
  
  📈 Dashboard: ${var.create_dashboard ? "✅ Creado en CloudWatch" : "❌ No creado"}
     ${var.create_dashboard ? "URL: https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}" : ""}
  
  🔔 Alarmas: ${var.create_alarms ? "✅ 2 alarmas configuradas" : "❌ Sin alarmas"}
  
  💰 ESTIMACIÓN DE COSTOS (us-east-1):
     - Ingesta: $0.50/GB
     - Almacenamiento: $0.03/GB/mes
     - Con ${var.log_retention_days} días de retención y ~1GB/mes de logs: ~$0.53-2/mes
  
  📊 GRAFANA:
     - Region: ${var.aws_region}
     - Log Groups: 3
     - Métricas personalizadas: ${var.create_metric_filters ? "✅ Habilitadas" : "❌ Deshabilitadas"}
  
  EOT
}
