# ============================================
# Backend de Terraform (S3 + DynamoDB Lock)
# ============================================
# NOTA: Descomentar después de crear el bucket y tabla manualmente
# o usar un script de inicialización

# terraform {
#   backend "s3" {
#     bucket         = "elmundo-fitness-terraform-state"
#     key            = "infrastructure/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
