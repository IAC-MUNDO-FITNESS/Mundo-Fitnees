# ============================================
# Outputs del Módulo VPC
# ============================================

output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID de la subnet pública"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID de la subnet privada"
  value       = aws_subnet.private.id
}

output "nat_gateway_id" {
  description = "ID del NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_ip" {
  description = "IP pública del NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "private_route_table_id" {
  description = "ID de la route table privada"
  value       = aws_route_table.private.id
}

output "s3_endpoint_id" {
  description = "ID del VPC Endpoint de S3"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "ID del VPC Endpoint de DynamoDB"
  value       = aws_vpc_endpoint.dynamodb.id
}
