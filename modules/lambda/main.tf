# ============================================
# Módulo Lambda - El Mundo Fitness
# ============================================

# Security Group para las Lambdas
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda-sg"
  description = "Security group para funciones Lambda"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permitir HTTPS hacia Internet"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permitir HTTP hacia Internet"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-lambda-sg"
    }
  )
}

# ============================================
# IAM ROLE PARA LAMBDAS
# ============================================

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution" {
  name               = "${var.project_name}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-lambda-role"
    }
  )
}

# Políticas básicas de Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Adjuntar política de CloudWatch Logs (siempre se crea primero en el módulo cloudwatch)
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = var.cloudwatch_policy_arn
}

# Adjuntar política de SES (siempre se crea primero en el módulo ses)
resource "aws_iam_role_policy_attachment" "lambda_ses" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = var.ses_policy_arn
}

# Política personalizada para DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = concat(
          var.dynamodb_table_arns,
          [for arn in var.dynamodb_table_arns : "${arn}/index/*"]
        )
      }
    ]
  })
}

# ============================================
# ARCHIVO ZIP PLACEHOLDER
# ============================================

data "archive_file" "lambda_placeholder" {
  type        = "zip"
  output_path = "${path.module}/lambda_placeholder.zip"

  source {
    content  = <<-EOF
      exports.handler = async (event) => {
        console.log('Event:', JSON.stringify(event, null, 2));
        return {
          statusCode: 200,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
          },
          body: JSON.stringify({
            message: 'Lambda function placeholder',
            timestamp: new Date().toISOString()
          })
        };
      };
    EOF
    filename = "index.js"
  }
}

# ============================================
# FUNCIONES LAMBDA
# ============================================

# Lambda 1: Subscription Control
resource "aws_lambda_function" "subscription_control" {
  filename         = data.archive_file.lambda_placeholder.output_path
  function_name    = "${var.project_name}-subscription-control"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      USUARIOS_TABLE        = var.usuarios_table_name
      ENVIRONMENT           = var.environment
      SES_SENDER_EMAIL      = var.ses_sender_email
      SES_CONFIGURATION_SET = var.ses_configuration_set
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-subscription-control"
    }
  )
}

# Lambda 2: Access Control
resource "aws_lambda_function" "access_control" {
  filename         = data.archive_file.lambda_placeholder.output_path
  function_name    = "${var.project_name}-access-control"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      HISTORIAL_TABLE = var.historial_table_name
      USUARIOS_TABLE  = var.usuarios_table_name
      ENVIRONMENT     = var.environment
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-access-control"
    }
  )
}

# Lambda 3: Notification Service
resource "aws_lambda_function" "notification_service" {
  filename         = data.archive_file.lambda_placeholder.output_path
  function_name    = "${var.project_name}-notification-service"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      USUARIOS_TABLE        = var.usuarios_table_name
      ENVIRONMENT           = var.environment
      SES_SENDER_EMAIL      = var.ses_sender_email
      SES_CONFIGURATION_SET = var.ses_configuration_set
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-notification-service"
    }
  )
}
