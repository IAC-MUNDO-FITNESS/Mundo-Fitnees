# ============================================
# Módulo Cognito - El Mundo Fitness
# ============================================

resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool"

  # Configuración de atributos
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Políticas de contraseña
  password_policy {
    minimum_length    = var.password_minimum_length
    require_lowercase = var.password_require_lowercase
    require_numbers   = var.password_require_numbers
    require_symbols   = var.password_require_symbols
    require_uppercase = var.password_require_uppercase
  }

  # Configuración de verificación de email
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "${var.project_name} - Código de Verificación"
    email_message        = "Tu código de verificación es {####}"
  }

  # Configuración de MFA (OFF por defecto para simplificar)
  mfa_configuration = "OFF"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-user-pool"
    }
  )
}

# Cliente de Cognito User Pool
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["phone", "email", "openid", "profile"]
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls

  supported_identity_providers = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

# Domain de Cognito
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-${var.account_id}"
  user_pool_id = aws_cognito_user_pool.main.id
}
