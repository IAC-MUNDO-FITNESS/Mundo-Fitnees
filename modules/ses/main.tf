# ============================================
# MÓDULO SES - Amazon Simple Email Service
# Validación de Email Identity para envío de recibos
# ============================================

# ============================================
# Email Identity (Validación de Correo)
# ============================================

resource "aws_ses_email_identity" "sender" {
  email = var.sender_email
}

# ============================================
# Verificación de DKIM (Domain Keys Identified Mail)
# Mejora la reputación de envío y evita spam
# ============================================

resource "aws_ses_domain_dkim" "sender_dkim" {
  count  = var.domain != "" ? 1 : 0
  domain = var.domain
}

# ============================================
# Configuration Set (Tracking y Métricas)
# ============================================

resource "aws_ses_configuration_set" "main" {
  name = "${var.project_name}-ses-config"

  delivery_options {
    tls_policy = "Require"
  }

  reputation_metrics_enabled = true
}

# ============================================
# SNS Topic para Bounce/Complaint Notifications
# ============================================

resource "aws_sns_topic" "ses_notifications" {
  count = var.enable_notifications ? 1 : 0
  name  = "${var.project_name}-ses-notifications"

  tags = var.tags
}

resource "aws_ses_identity_notification_topic" "bounce" {
  count                    = var.enable_notifications ? 1 : 0
  topic_arn                = aws_sns_topic.ses_notifications[0].arn
  notification_type        = "Bounce"
  identity                 = aws_ses_email_identity.sender.email
  include_original_headers = true
}

resource "aws_ses_identity_notification_topic" "complaint" {
  count                    = var.enable_notifications ? 1 : 0
  topic_arn                = aws_sns_topic.ses_notifications[0].arn
  notification_type        = "Complaint"
  identity                 = aws_ses_email_identity.sender.email
  include_original_headers = true
}

# ============================================
# IAM Policy para Lambda (Enviar Emails)
# ============================================

data "aws_iam_policy_document" "ses_send_email" {
  statement {
    sid    = "AllowSESSendEmail"
    effect = "Allow"

    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
      "ses:SendTemplatedEmail"
    ]

    resources = [
      aws_ses_email_identity.sender.arn,
      "arn:aws:ses:${var.aws_region}:${var.account_id}:configuration-set/${aws_ses_configuration_set.main.name}"
    ]

    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = [var.sender_email]
    }
  }

  statement {
    sid    = "AllowSESGetSendQuota"
    effect = "Allow"

    actions = [
      "ses:GetSendQuota",
      "ses:GetSendStatistics"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_send_email" {
  name        = "${var.project_name}-ses-send-email"
  description = "Permite a las Lambdas enviar emails vía SES"
  policy      = data.aws_iam_policy_document.ses_send_email.json

  tags = var.tags
}

# ============================================
# Email Templates (Recibos, Notificaciones)
# ============================================

resource "aws_ses_template" "receipt" {
  count = var.create_receipt_template ? 1 : 0
  name  = "${var.project_name}-receipt-template"

  subject = "Recibo de Pago - {{subscription_type}}"

  html = <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background-color: #f9f9f9; }
        .footer { text-align: center; padding: 10px; font-size: 12px; color: #777; }
        .amount { font-size: 24px; font-weight: bold; color: #4CAF50; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>El Mundo Fitness</h1>
          <p>Recibo de Pago</p>
        </div>
        <div class="content">
          <p>Hola <strong>{{customer_name}}</strong>,</p>
          <p>Gracias por tu pago. A continuación los detalles:</p>
          <ul>
            <li><strong>Fecha:</strong> {{payment_date}}</li>
            <li><strong>Tipo de Suscripción:</strong> {{subscription_type}}</li>
            <li><strong>Monto:</strong> <span class="amount">{{amount}}</span></li>
            <li><strong>ID de Transacción:</strong> {{transaction_id}}</li>
          </ul>
          <p>Tu suscripción está activa hasta: <strong>{{expiration_date}}</strong></p>
        </div>
        <div class="footer">
          <p>El Mundo Fitness &copy; 2024-2025 | Todos los derechos reservados</p>
        </div>
      </div>
    </body>
    </html>
  HTML

  text = <<-TEXT
    El Mundo Fitness - Recibo de Pago
    
    Hola {{customer_name}},
    
    Gracias por tu pago. A continuación los detalles:
    
    Fecha: {{payment_date}}
    Tipo de Suscripción: {{subscription_type}}
    Monto: {{amount}}
    ID de Transacción: {{transaction_id}}
    
    Tu suscripción está activa hasta: {{expiration_date}}
    
    El Mundo Fitness © 2024-2025 | Todos los derechos reservados
  TEXT
}

resource "aws_ses_template" "notification" {
  count = var.create_notification_template ? 1 : 0
  name  = "${var.project_name}-notification-template"

  subject = "{{subject}}"

  html = <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #2196F3; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background-color: #f9f9f9; }
        .footer { text-align: center; padding: 10px; font-size: 12px; color: #777; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>El Mundo Fitness</h1>
        </div>
        <div class="content">
          <p>Hola <strong>{{customer_name}}</strong>,</p>
          <p>{{message}}</p>
        </div>
        <div class="footer">
          <p>El Mundo Fitness &copy; 2024-2025 | Todos los derechos reservados</p>
        </div>
      </div>
    </body>
    </html>
  HTML

  text = <<-TEXT
    El Mundo Fitness
    
    Hola {{customer_name}},
    
    {{message}}
    
    El Mundo Fitness © 2024-2025 | Todos los derechos reservados
  TEXT
}
