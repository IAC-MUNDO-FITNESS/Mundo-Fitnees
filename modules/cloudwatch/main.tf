# ============================================
# MÓDULO CLOUDWATCH - Logs y Monitoreo
# Gestión explícita de logs de Lambda con retention
# ============================================

# ============================================
# Log Groups para Lambda Functions
# ============================================

resource "aws_cloudwatch_log_group" "subscription_control" {
  name              = "/aws/lambda/${var.subscription_control_function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_encryption ? aws_kms_key.cloudwatch[0].arn : null

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-subscription-control-logs"
      Lambda      = var.subscription_control_function_name
      Environment = var.environment
    }
  )
}

resource "aws_cloudwatch_log_group" "access_control" {
  name              = "/aws/lambda/${var.access_control_function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_encryption ? aws_kms_key.cloudwatch[0].arn : null

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-access-control-logs"
      Lambda      = var.access_control_function_name
      Environment = var.environment
    }
  )
}

resource "aws_cloudwatch_log_group" "notification_service" {
  name              = "/aws/lambda/${var.notification_service_function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_encryption ? aws_kms_key.cloudwatch[0].arn : null

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-notification-service-logs"
      Lambda      = var.notification_service_function_name
      Environment = var.environment
    }
  )
}

# ============================================
# KMS Key para Encriptación de Logs (Opcional)
# ============================================

resource "aws_kms_key" "cloudwatch" {
  count = var.enable_encryption ? 1 : 0

  description             = "KMS key para encriptar logs de CloudWatch"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cloudwatch-kms"
    }
  )
}

resource "aws_kms_alias" "cloudwatch" {
  count = var.enable_encryption ? 1 : 0

  name          = "alias/${var.project_name}-cloudwatch-logs"
  target_key_id = aws_kms_key.cloudwatch[0].key_id
}

# ============================================
# IAM Policy para Lambda (Escribir en CloudWatch)
# ============================================

data "aws_iam_policy_document" "lambda_cloudwatch" {
  statement {
    sid    = "AllowCreateLogGroup"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:*"
    ]
  }

  statement {
    sid    = "AllowWriteLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.subscription_control.arn,
      aws_cloudwatch_log_group.access_control.arn,
      aws_cloudwatch_log_group.notification_service.arn,
      "${aws_cloudwatch_log_group.subscription_control.arn}:*",
      "${aws_cloudwatch_log_group.access_control.arn}:*",
      "${aws_cloudwatch_log_group.notification_service.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_cloudwatch" {
  name        = "${var.project_name}-lambda-cloudwatch-logs"
  description = "Permite a las Lambdas escribir en CloudWatch Logs"
  policy      = data.aws_iam_policy_document.lambda_cloudwatch.json

  tags = var.tags
}

# ============================================
# Metric Filters (Alarmas Personalizadas)
# ============================================

# Filtro para errores en Subscription Control
resource "aws_cloudwatch_log_metric_filter" "subscription_errors" {
  count = var.create_metric_filters ? 1 : 0

  name           = "${var.project_name}-subscription-errors"
  log_group_name = aws_cloudwatch_log_group.subscription_control.name
  pattern        = "[ERROR]"

  metric_transformation {
    name      = "SubscriptionErrors"
    namespace = "${var.project_name}/Lambda"
    value     = "1"
    default_value = 0
  }
}

# Filtro para pagos exitosos
resource "aws_cloudwatch_log_metric_filter" "successful_payments" {
  count = var.create_metric_filters ? 1 : 0

  name           = "${var.project_name}-successful-payments"
  log_group_name = aws_cloudwatch_log_group.subscription_control.name
  pattern        = "[payment_success]"

  metric_transformation {
    name      = "SuccessfulPayments"
    namespace = "${var.project_name}/Lambda"
    value     = "1"
    default_value = 0
  }
}

# Filtro para errores de acceso
resource "aws_cloudwatch_log_metric_filter" "access_denied" {
  count = var.create_metric_filters ? 1 : 0

  name           = "${var.project_name}-access-denied"
  log_group_name = aws_cloudwatch_log_group.access_control.name
  pattern        = "[access_denied]"

  metric_transformation {
    name      = "AccessDenied"
    namespace = "${var.project_name}/Lambda"
    value     = "1"
    default_value = 0
  }
}

# ============================================
# CloudWatch Alarms
# ============================================

resource "aws_cloudwatch_metric_alarm" "subscription_errors_high" {
  count = var.create_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-subscription-errors-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "SubscriptionErrors"
  namespace           = "${var.project_name}/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alerta cuando hay más de 5 errores en Subscription Lambda en 10 minutos"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.sns_alarm_topic_arn != "" ? [var.sns_alarm_topic_arn] : []

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  count = var.create_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-lambda-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alerta cuando las Lambdas son throttled (límite de concurrencia)"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = var.subscription_control_function_name
  }

  alarm_actions = var.sns_alarm_topic_arn != "" ? [var.sns_alarm_topic_arn] : []

  tags = var.tags
}

# ============================================
# Log Insights Queries (Guardadas)
# ============================================

resource "aws_cloudwatch_query_definition" "lambda_errors" {
  count = var.create_saved_queries ? 1 : 0

  name = "${var.project_name}/errors-last-hour"

  log_group_names = [
    aws_cloudwatch_log_group.subscription_control.name,
    aws_cloudwatch_log_group.access_control.name,
    aws_cloudwatch_log_group.notification_service.name
  ]

  query_string = <<-QUERY
    fields @timestamp, @message, @logStream
    | filter @message like /ERROR/
    | sort @timestamp desc
    | limit 100
  QUERY
}

resource "aws_cloudwatch_query_definition" "slow_requests" {
  count = var.create_saved_queries ? 1 : 0

  name = "${var.project_name}/slow-requests"

  log_group_names = [
    aws_cloudwatch_log_group.subscription_control.name,
    aws_cloudwatch_log_group.access_control.name,
    aws_cloudwatch_log_group.notification_service.name
  ]

  query_string = <<-QUERY
    fields @timestamp, @duration, @requestId, @logStream
    | filter @type = "REPORT"
    | filter @duration > 3000
    | sort @duration desc
    | limit 50
  QUERY
}

resource "aws_cloudwatch_query_definition" "payments_summary" {
  count = var.create_saved_queries ? 1 : 0

  name = "${var.project_name}/payments-summary"

  log_group_names = [
    aws_cloudwatch_log_group.subscription_control.name
  ]

  query_string = <<-QUERY
    fields @timestamp, @message
    | filter @message like /payment_success/ or @message like /payment_failed/
    | stats count(*) as total by bin(5m)
  QUERY
}

# ============================================
# Dashboard para Grafana (Exportado como JSON)
# ============================================

resource "aws_cloudwatch_dashboard" "main" {
  count = var.create_dashboard ? 1 : 0

  dashboard_name = "${var.project_name}-lambda-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum", label = "Invocations" }],
            [".", "Errors", { stat = "Sum", label = "Errors" }],
            [".", "Duration", { stat = "Average", label = "Avg Duration" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Lambda Metrics Overview"
        }
      },
      {
        type = "log"
        properties = {
          query   = "SOURCE '${aws_cloudwatch_log_group.subscription_control.name}' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20"
          region  = var.aws_region
          title   = "Recent Errors"
        }
      }
    ]
  })
}
