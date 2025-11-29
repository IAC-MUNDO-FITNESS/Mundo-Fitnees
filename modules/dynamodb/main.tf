# ============================================
# Módulo DynamoDB - El Mundo Fitness
# ============================================

# Tabla de Usuarios
resource "aws_dynamodb_table" "usuarios" {
  name         = "${var.project_name}-usuarios"
  billing_mode = var.billing_mode
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name            = "EmailIndex"
    hash_key        = "email"
    projection_type = "ALL"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-usuarios"
    }
  )
}

# Tabla de Pagos
resource "aws_dynamodb_table" "pagos" {
  name         = "${var.project_name}-pagos"
  billing_mode = var.billing_mode
  hash_key     = "pagoId"
  range_key    = "timestamp"

  attribute {
    name = "pagoId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-pagos"
    }
  )
}

# Tabla de Historial de Asistencia
resource "aws_dynamodb_table" "historial_asistencia" {
  name         = "${var.project_name}-historial-asistencia"
  billing_mode = var.billing_mode
  hash_key     = "asistenciaId"
  range_key    = "timestamp"

  attribute {
    name = "asistenciaId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-historial-asistencia"
    }
  )
}
