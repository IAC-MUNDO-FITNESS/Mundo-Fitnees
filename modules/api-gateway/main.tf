# ============================================
# Módulo API Gateway - El Mundo Fitness
# ============================================

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
  description   = "API HTTP para ${var.project_name}"

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
    max_age       = var.cors_max_age
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-api"
    }
  )
}

# ============================================
# COGNITO AUTHORIZER
# ============================================

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.project_name}-cognito-authorizer"

  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = "https://${var.cognito_user_pool_endpoint}"
  }
}

# Stage de API Gateway
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-api-stage"
    }
  )
}

# ============================================
# INTEGRACIONES LAMBDA
# ============================================

# Integración Lambda 1: Subscription Control
resource "aws_apigatewayv2_integration" "subscription_control" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.subscription_control_invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "subscription_control" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /subscription"
  target             = "integrations/${aws_apigatewayv2_integration.subscription_control.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_lambda_permission" "subscription_control" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.subscription_control_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# Integración Lambda 2: Access Control
resource "aws_apigatewayv2_integration" "access_control" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.access_control_invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "access_control" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /access"
  target             = "integrations/${aws_apigatewayv2_integration.access_control.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_lambda_permission" "access_control" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.access_control_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# Integración Lambda 3: Notification Service
resource "aws_apigatewayv2_integration" "notification_service" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.notification_service_invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "notification_service" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /notification"
  target    = "integrations/${aws_apigatewayv2_integration.notification_service.id}"
}

resource "aws_lambda_permission" "notification_service" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.notification_service_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
