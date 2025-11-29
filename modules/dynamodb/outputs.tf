# ============================================
# Outputs del Módulo DynamoDB
# ============================================

output "usuarios_table_name" {
  description = "Nombre de la tabla de Usuarios"
  value       = aws_dynamodb_table.usuarios.name
}

output "usuarios_table_arn" {
  description = "ARN de la tabla de Usuarios"
  value       = aws_dynamodb_table.usuarios.arn
}

output "pagos_table_name" {
  description = "Nombre de la tabla de Pagos"
  value       = aws_dynamodb_table.pagos.name
}

output "pagos_table_arn" {
  description = "ARN de la tabla de Pagos"
  value       = aws_dynamodb_table.pagos.arn
}

output "historial_table_name" {
  description = "Nombre de la tabla de Historial de Asistencia"
  value       = aws_dynamodb_table.historial_asistencia.name
}

output "historial_table_arn" {
  description = "ARN de la tabla de Historial de Asistencia"
  value       = aws_dynamodb_table.historial_asistencia.arn
}

output "all_table_arns" {
  description = "Lista de ARNs de todas las tablas"
  value = [
    aws_dynamodb_table.usuarios.arn,
    aws_dynamodb_table.pagos.arn,
    aws_dynamodb_table.historial_asistencia.arn
  ]
}
