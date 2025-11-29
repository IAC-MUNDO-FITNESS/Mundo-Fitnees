# ============================================
# Outputs - Módulo SES
# ============================================

output "email_identity_arn" {
  description = "ARN de la identidad de email verificada"
  value       = aws_ses_email_identity.sender.arn
}

output "sender_email" {
  description = "Email address configurado para envío"
  value       = aws_ses_email_identity.sender.email
}

output "configuration_set_name" {
  description = "Nombre del Configuration Set de SES"
  value       = aws_ses_configuration_set.main.name
}

output "configuration_set_arn" {
  description = "ARN del Configuration Set de SES"
  value       = aws_ses_configuration_set.main.arn
}

output "ses_policy_arn" {
  description = "ARN de la política IAM para enviar emails (adjuntar a Lambda roles)"
  value       = aws_iam_policy.ses_send_email.arn
}

output "ses_policy_name" {
  description = "Nombre de la política IAM de SES"
  value       = aws_iam_policy.ses_send_email.name
}

output "receipt_template_name" {
  description = "Nombre del template de recibos"
  value       = var.create_receipt_template ? aws_ses_template.receipt[0].name : ""
}

output "notification_template_name" {
  description = "Nombre del template de notificaciones"
  value       = var.create_notification_template ? aws_ses_template.notification[0].name : ""
}

output "sns_topic_arn" {
  description = "ARN del SNS topic para notificaciones de SES (bounce/complaint)"
  value       = var.enable_notifications ? aws_sns_topic.ses_notifications[0].arn : ""
}

output "verification_status" {
  description = "Instrucciones para verificar el email"
  value = <<-EOT
  
  ⚠️  ACCIÓN REQUERIDA: Verificar Email Identity
  
  1. Revisa tu correo: ${aws_ses_email_identity.sender.email}
  2. AWS SES envió un email de verificación
  3. Haz clic en el enlace de verificación
  4. Una vez verificado, puedes enviar emails
  
  Para verificar manualmente:
  aws ses verify-email-identity --email-address ${aws_ses_email_identity.sender.email} --region ${var.aws_region}
  
  Para salir del Sandbox (modo producción):
  1. Abre AWS Console > SES > Account Dashboard
  2. Solicita "Request production access"
  3. Completa el formulario justificando el uso
  
  En modo Sandbox solo puedes enviar a:
  - Emails verificados
  - Máximo 200 emails/día
  - 1 email/segundo
  
  EOT
}
