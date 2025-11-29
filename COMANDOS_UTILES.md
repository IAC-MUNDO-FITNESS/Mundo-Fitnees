# ============================================
# GUÍA RÁPIDA DE COMANDOS - EL MUNDO FITNESS
# ============================================

## CONFIGURACIÓN INICIAL DE AWS

# Configurar credenciales de AWS (en tu máquina local)
aws configure

# Verificar que las credenciales funcionen
aws sts get-caller-identity

# Ver la región configurada
aws configure get region


## COMANDOS DE TERRAFORM

# Inicializar Terraform (primera vez)
terraform init

# Validar la sintaxis del código
terraform validate

# Formatear el código Terraform
terraform fmt -recursive

# Ver el plan de ejecución (qué se va a crear)
terraform plan

# Ver el plan con variables específicas
terraform plan -var="environment=dev"

# Aplicar cambios (con confirmación manual)
terraform apply

# Aplicar cambios sin confirmación
terraform apply -auto-approve

# Aplicar con variables específicas
terraform apply -var="environment=prod" -var="project_name=mi-proyecto"

# Ver todos los outputs
terraform output

# Ver un output específico
terraform output api_gateway_endpoint

# Ver outputs en formato JSON
terraform output -json

# Destruir toda la infraestructura
terraform destroy

# Destruir sin confirmación (¡PELIGROSO!)
terraform destroy -auto-approve

# Ver el estado actual
terraform show

# Listar recursos en el estado
terraform state list

# Refrescar el estado sin modificar recursos
terraform refresh


## COMANDOS DE AWS CLI ÚTILES

# Listar funciones Lambda
aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime,LastModified]' --output table

# Ver logs de una Lambda específica
aws logs tail /aws/lambda/elmundo-fitness-subscription-control-dev --follow

# Listar tablas DynamoDB
aws dynamodb list-tables

# Describir una tabla DynamoDB
aws dynamodb describe-table --table-name elmundo-fitness-usuarios-dev

# Listar buckets S3
aws s3 ls

# Ver VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table

# Ver subnets
aws ec2 describe-subnets --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' --output table

# Ver NAT Gateways
aws ec2 describe-nat-gateways --query 'NatGateways[*].[NatGatewayId,State,SubnetId]' --output table

# Ver API Gateways
aws apigatewayv2 get-apis --query 'Items[*].[Name,ApiId,ApiEndpoint]' --output table

# Ver Cognito User Pools
aws cognito-idp list-user-pools --max-results 10 --query 'UserPools[*].[Name,Id]' --output table


## COMANDOS DE DEBUGGING

# Ver detalles de un recurso específico en el estado
terraform state show aws_vpc.main

# Importar un recurso existente al estado de Terraform
terraform import aws_vpc.main vpc-xxxxxxxxx

# Eliminar un recurso del estado (sin destruirlo en AWS)
terraform state rm aws_vpc.main

# Mover un recurso en el estado
terraform state mv aws_vpc.main aws_vpc.main_new

# Verificar el gráfico de dependencias
terraform graph | dot -Tpng > graph.png


## TROUBLESHOOTING

# Limpiar la caché de Terraform
rm -rf .terraform
terraform init

# Forzar desbloqueo del estado (si hay un lock atascado)
terraform force-unlock <LOCK_ID>

# Ver logs detallados de Terraform
export TF_LOG=DEBUG
terraform apply
unset TF_LOG

# Ver logs de Terraform en un archivo
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform apply

# Validar la configuración de AWS CLI
aws sts get-caller-identity
aws configure list


## COMANDOS DE JENKINS CLI (Opcional)

# Descargar Jenkins CLI
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

# Ejecutar un job
java -jar jenkins-cli.jar -s http://localhost:8080/ build ElMundoFitness-IaC

# Ver el log de la última ejecución
java -jar jenkins-cli.jar -s http://localhost:8080/ console ElMundoFitness-IaC


## CREACIÓN DE BACKEND REMOTO (S3 + DynamoDB)

# Crear bucket para el estado de Terraform
aws s3api create-bucket \
  --bucket elmundo-fitness-terraform-state \
  --region us-east-1

# Habilitar versionado en el bucket
aws s3api put-bucket-versioning \
  --bucket elmundo-fitness-terraform-state \
  --versioning-configuration Status=Enabled

# Habilitar encriptación en el bucket
aws s3api put-bucket-encryption \
  --bucket elmundo-fitness-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Crear tabla DynamoDB para el lock
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1


## TESTING DE LOS ENDPOINTS

# Test del endpoint de Subscription
curl -X POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev/subscription \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user-123",
    "email": "test@example.com",
    "subscriptionType": "monthly"
  }'

# Test del endpoint de Access Control
curl -X POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev/access \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user-123",
    "action": "check-in"
  }'

# Test del endpoint de Notification
curl -X POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev/notification \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user-123",
    "message": "Tu suscripción está por vencer"
  }'


## MONITOREO Y LOGS

# Ver métricas de Lambda
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=elmundo-fitness-subscription-control-dev \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum

# Ver logs recientes de Lambda
aws logs tail /aws/lambda/elmundo-fitness-subscription-control-dev --since 1h

# Crear alerta en CloudWatch
aws cloudwatch put-metric-alarm \
  --alarm-name lambda-errors \
  --alarm-description "Alert on Lambda errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold


## LIMPIEZA MANUAL (Si terraform destroy falla)

# Eliminar funciones Lambda
aws lambda delete-function --function-name elmundo-fitness-subscription-control-dev
aws lambda delete-function --function-name elmundo-fitness-access-control-dev
aws lambda delete-function --function-name elmundo-fitness-notification-service-dev

# Eliminar API Gateway
aws apigatewayv2 delete-api --api-id YOUR_API_ID

# Eliminar tablas DynamoDB
aws dynamodb delete-table --table-name elmundo-fitness-usuarios-dev
aws dynamodb delete-table --table-name elmundo-fitness-pagos-dev
aws dynamodb delete-table --table-name elmundo-fitness-historial-asistencia-dev

# Vaciar y eliminar bucket S3
aws s3 rm s3://elmundo-fitness-frontend-dev-ACCOUNT_ID --recursive
aws s3api delete-bucket --bucket elmundo-fitness-frontend-dev-ACCOUNT_ID

# Eliminar Cognito User Pool
aws cognito-idp delete-user-pool --user-pool-id YOUR_USER_POOL_ID

# Eliminar NAT Gateway (esperar a que se complete)
aws ec2 delete-nat-gateway --nat-gateway-id nat-xxxxxxxxx

# Liberar Elastic IP
aws ec2 release-address --allocation-id eipalloc-xxxxxxxxx

# Eliminar VPC (después de eliminar todo lo demás)
aws ec2 delete-vpc --vpc-id vpc-xxxxxxxxx


## VARIABLES DE ENTORNO ÚTILES

# Para debugging de Terraform
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Para configurar AWS
export AWS_PROFILE=default
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1

# Para usar credenciales temporales
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_SESSION_TOKEN=your-session-token
