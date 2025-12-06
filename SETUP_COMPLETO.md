# 🚀 Guía de Configuración Completa - Mundo Fitness

## 📋 Índice
1. [Requisitos Previos](#requisitos-previos)
2. [Instalación Inicial](#instalación-inicial)
3. [Configuración de AWS](#configuración-de-aws)
4. [Configuración de Docker y Servicios](#configuración-de-docker-y-servicios)
5. [Configuración de Jenkins](#configuración-de-jenkins)
6. [Configuración de SonarQube](#configuración-de-sonarqube)
7. [Configuración de Grafana](#configuración-de-grafana)
8. [Ejecución del Pipeline](#ejecución-del-pipeline)
9. [Verificación Final](#verificación-final)
10. [Troubleshooting](#troubleshooting)

---

## 🔧 Requisitos Previos

### Software Necesario
- **Git**: [Descargar Git](https://git-scm.com/downloads)
- **Docker Desktop**: [Descargar Docker](https://www.docker.com/products/docker-desktop)
- **Node.js 18+**: [Descargar Node.js](https://nodejs.org/)
- **Cuenta AWS**: [Crear cuenta AWS](https://aws.amazon.com/)
- **AWS CLI**: [Instalar AWS CLI](https://aws.amazon.com/cli/)

### Verificar Instalaciones
```powershell
# Verificar Git
git --version

# Verificar Docker
docker --version
docker-compose --version

# Verificar Node.js
node --version
npm --version

# Verificar AWS CLI
aws --version
```

---

## 📥 Instalación Inicial

### 1. Clonar el Repositorio
```powershell
# Navegar a tu carpeta de proyectos
cd C:\Users\TuUsuario\

# Clonar el repositorio
git clone https://github.com/IAC-MUNDO-FITNESS/Mundo-Fitnees.git

# Entrar al directorio
cd Mundo-Fitnees
```

### 2. Instalar Dependencias de Node.js
```powershell
# Instalar dependencias para los tests
npm install
```

---

## ☁️ Configuración de AWS

### 1. Crear Usuario IAM
1. Inicia sesión en [AWS Console](https://console.aws.amazon.com/)
2. Ve a **IAM** → **Users** → **Add users**
3. Nombre: `terraform-user`
4. Selecciona: **Programmatic access**
5. Permisos: **AdministratorAccess** (para desarrollo)
6. **Guarda las credenciales**:
   - Access Key ID
   - Secret Access Key

### 2. Configurar AWS CLI
```powershell
# Configurar credenciales
aws configure

# Ingresa los valores cuando te los pida:
AWS Access Key ID: [TU_ACCESS_KEY]
AWS Secret Access Key: [TU_SECRET_KEY]
Default region name: us-east-1
Default output format: json
```

### 3. Verificar Configuración
```powershell
# Verificar que AWS CLI funciona
aws sts get-caller-identity

# Deberías ver tu Account ID, UserId, y ARN
```

### 4. Obtener tu Account ID
```powershell
# Guardar Account ID (lo necesitarás después)
aws sts get-caller-identity --query Account --output text
```

### 5. Crear Archivo terraform.tfvars
```powershell
# Crear archivo de variables
@"
aws_region     = "us-east-1"
environment    = "dev"
project_name   = "elmundo-fitness"
aws_account_id = "TU_ACCOUNT_ID_AQUI"  # Reemplaza con el Account ID del paso anterior
sender_email   = "tu-email@gmail.com"   # Tu email para SES
"@ | Out-File -FilePath terraform.tfvars -Encoding UTF8
```

---

## 🐳 Configuración de Docker y Servicios

### 1. Iniciar Docker Desktop
- Abre **Docker Desktop**
- Asegúrate que esté corriendo (icono en la bandeja del sistema)

### 2. Levantar Todos los Servicios
```powershell
# Levantar Jenkins, SonarQube, Grafana y PostgreSQL
docker-compose up -d

# Ver logs para confirmar que todo está iniciando
docker-compose logs -f

# Presiona Ctrl+C cuando veas que todos los servicios están "Ready"
```

### 3. Verificar que los Contenedores Están Running
```powershell
docker-compose ps

# Deberías ver 4 contenedores RUNNING:
# - elmundo-fitness-jenkins
# - elmundo-fitness-sonarqube
# - elmundo-fitness-grafana
# - elmundo-fitness-sonarqube-db
```

### 4. Esperar a que los Servicios Estén Listos
```powershell
# Jenkins tarda ~2 minutos
# SonarQube tarda ~3 minutos
# Grafana tarda ~30 segundos

# Verificar logs de cada servicio:
docker logs elmundo-fitness-jenkins
docker logs elmundo-fitness-sonarqube
docker logs elmundo-fitness-grafana
```

---

## 🔨 Configuración de Jenkins

### 1. Obtener Contraseña Inicial
```powershell
# Obtener la contraseña de administrador
docker exec elmundo-fitness-jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Copia la contraseña que aparece
```

### 2. Acceder a Jenkins
1. Abre navegador: http://localhost:8080
2. Pega la contraseña inicial
3. **Selecciona**: "Install suggested plugins"
4. **Espera** a que se instalen todos los plugins (~5 minutos)

### 3. Crear Usuario Administrador
- **Username**: `admin`
- **Password**: `admin` (o la que prefieras)
- **Full name**: `Administrator`
- **Email**: `tu-email@gmail.com`
- Click **Save and Continue**

### 4. Configurar URL de Jenkins
- Dejar por defecto: `http://localhost:8080/`
- Click **Save and Finish**
- Click **Start using Jenkins**

### 5. Crear Pipeline Job
1. Click **"New Item"**
2. **Name**: `Mundo-Fitness-Pipeline`
3. **Type**: **Pipeline**
4. Click **OK**

### 6. Configurar Pipeline
1. En **Pipeline** section:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/IAC-MUNDO-FITNESS/Mundo-Fitnees.git`
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`
2. Click **Save**

### 7. Configurar Credenciales de AWS en Jenkins
1. Ve a: **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
2. Click **Add Credentials**
3. **Credencial 1 - AWS Access Key**:
   - **Kind**: Secret text
   - **Scope**: Global
   - **Secret**: [Tu AWS Access Key ID]
   - **ID**: `AWS_ACCESS_KEY_ID`
   - **Description**: AWS Access Key
   - Click **Create**

4. Click **Add Credentials** nuevamente
5. **Credencial 2 - AWS Secret Key**:
   - **Kind**: Secret text
   - **Scope**: Global
   - **Secret**: [Tu AWS Secret Access Key]
   - **ID**: `AWS_SECRET_ACCESS_KEY`
   - **Description**: AWS Secret Access Key
   - Click **Create**

6. Click **Add Credentials** nuevamente
7. **Credencial 3 - AWS Account ID**:
   - **Kind**: Secret text
   - **Scope**: Global
   - **Secret**: [Tu AWS Account ID]
   - **ID**: `AWS_ACCOUNT_ID`
   - **Description**: AWS Account ID
   - Click **Create**

---

## 🔍 Configuración de SonarQube

### 1. Acceder a SonarQube
1. Abre navegador: http://localhost:9000
2. **Login inicial**:
   - Username: `admin`
   - Password: `admin`
3. **Te pedirá cambiar la contraseña**:
   - Old Password: `admin`
   - New Password: `admin123` (o la que prefieras)
   - Confirm Password: `admin123`
   - Click **Update**

### 2. Crear Proyecto en SonarQube
1. Click **"Create Project"** (botón azul)
2. **Project key**: `elmundo-fitness`
3. **Display name**: `El Mundo Fitness`
4. Click **Set Up**

### 3. Generar Token de Análisis
1. Selecciona **"Locally"**
2. **Token name**: `jenkins-token`
3. **Expires in**: Select **No expiration**
4. Click **Generate**
5. **¡IMPORTANTE!** Copia el token que aparece (ejemplo: `squ_1234567890abcdef...`)
6. **Guárdalo** en un lugar seguro (solo se muestra una vez)

### 4. Configurar Token en Jenkins
1. Ve a Jenkins: http://localhost:8080
2. **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
3. Click **Add Credentials**
4. **Configurar**:
   - **Kind**: Secret text
   - **Scope**: Global
   - **Secret**: [Pega el token de SonarQube que copiaste]
   - **ID**: `SONARQUBE_TOKEN`
   - **Description**: SonarQube Analysis Token
5. Click **Create**

---

## 📊 Configuración de Grafana

### 1. Acceder a Grafana
1. Abre navegador: http://localhost:3000
2. **Login inicial**:
   - Username: `admin`
   - Password: `admin`
3. **Te pedirá cambiar la contraseña**:
   - New password: `admin123` (o la que prefieras)
   - Confirm: `admin123`
   - Click **Submit**

### 2. Configurar AWS CloudWatch como Data Source
1. Click **"Configuration"** (⚙️ icono) → **Data Sources**
2. Click **"Add data source"**
3. Busca y selecciona **"CloudWatch"**
4. **Configurar**:
   - **Name**: `CloudWatch-ElMundoFitness`
   - **Default Region**: `us-east-1`
   - **Auth Provider**: `Access & secret key`
   - **Access Key ID**: [Tu AWS Access Key ID]
   - **Secret Access Key**: [Tu AWS Secret Access Key]
5. Click **"Save & Test"**
6. Deberías ver: ✅ **"Successfully queried the CloudWatch API"**

### 3. Importar Dashboard
1. Click **"+"** (más) → **Import**
2. Click **"Upload JSON file"**
3. Selecciona: `grafana/dashboards/lambda-monitoring.json`
4. **Selecciona Data Source**: CloudWatch-ElMundoFitness
5. Click **Import**

---

## 🚀 Ejecución del Pipeline

### 1. Primera Ejecución - Terraform Plan
1. Ve a Jenkins: http://localhost:8080
2. Click en **"Mundo-Fitness-Pipeline"**
3. Click **"Build with Parameters"**
4. **Configurar**:
   - **ACTION**: `plan`
   - **ENVIRONMENT**: `dev`
5. Click **"Build"**

### 2. Monitorear la Ejecución
1. Click en el número del build (ej: **#1**)
2. Click **"Console Output"**
3. Observa el progreso:
   - ✅ Checkout
   - ✅ Unit Tests
   - ✅ Security Scan (Checkov)
   - ✅ SonarQube Analysis
   - ✅ Terraform Init
   - ✅ Terraform Validate
   - ✅ Terraform Plan

### 3. Revisar el Plan de Terraform
En el Console Output, verás:
```
Plan: 70 to add, 0 to change, 0 to destroy.
```

### 4. Revisar Análisis de SonarQube
1. Ve a SonarQube: http://localhost:9000
2. Click en proyecto **"elmundo-fitness"**
3. Revisa:
   - **Quality Gate**: PASSED/FAILED
   - **Bugs**: Cantidad encontrada
   - **Vulnerabilities**: Problemas de seguridad
   - **Code Smells**: Problemas de mantenibilidad
   - **Coverage**: Cobertura de tests

### 5. Segunda Ejecución - Terraform Apply
**⚠️ IMPORTANTE**: Esta ejecución creará recursos reales en AWS (tiene costo).

1. Ve a Jenkins
2. Click **"Build with Parameters"**
3. **Configurar**:
   - **ACTION**: `apply`
   - **ENVIRONMENT**: `dev`
4. Click **"Build"**
5. **Espera aprobación manual**:
   - Verás un mensaje: "Waiting for approval"
   - Click **"Proceed"** para confirmar
6. Jenkins ejecutará `terraform apply`
7. Espera ~10-15 minutos (crea 70 recursos en AWS)

---

## ✅ Verificación Final

### 1. Verificar Recursos en AWS Console
```powershell
# Listar Lambdas creadas
aws lambda list-functions --query 'Functions[?contains(FunctionName, `elmundo-fitness`)].FunctionName'

# Listar tablas DynamoDB
aws dynamodb list-tables --query 'TableNames[?contains(@, `elmundo-fitness`)]'

# Listar buckets S3
aws s3 ls | findstr elmundo-fitness

# Listar API Gateways
aws apigatewayv2 get-apis --query 'Items[?contains(Name, `elmundo-fitness`)].Name'
```

### 2. Verificar Outputs de Terraform
En Jenkins Console Output, al final verás:
```
Outputs:

api_gateway_url = "https://xxxxx.execute-api.us-east-1.amazonaws.com"
cloudfront_url = "https://xxxxx.cloudfront.net"
cognito_user_pool_id = "us-east-1_xxxxx"
...
```

### 3. Verificar Dashboards

**Jenkins**: http://localhost:8080
- Pipeline ejecutado exitosamente
- Tests pasando
- Security scan completo

**SonarQube**: http://localhost:9000
- Quality Gate: PASSED
- Análisis completo del código

**Grafana**: http://localhost:3000
- Dashboard de Lambda Metrics
- Gráficas de invocaciones, errores, duración

### 4. Verificar SES Email
```powershell
# Verificar estado del email en SES
aws ses get-identity-verification-attributes --identities tu-email@gmail.com

# Revisa tu correo para verificar el email de AWS SES
```

---

## 🔧 Troubleshooting

### Problema: Docker no inicia
**Solución**:
```powershell
# Reiniciar Docker Desktop
# Desde PowerShell como Administrador:
Restart-Service docker

# O reinicia Docker Desktop desde el menú de la aplicación
```

### Problema: Jenkins no muestra plugins instalados
**Solución**:
```powershell
# Verificar logs
docker logs elmundo-fitness-jenkins

# Reiniciar Jenkins
docker restart elmundo-fitness-jenkins

# Esperar 2 minutos y recargar http://localhost:8080
```

### Problema: SonarQube muestra error "Not authorized"
**Solución**:
1. Verifica que el token en Jenkins sea correcto
2. Ve a Jenkins → Credentials → SONARQUBE_TOKEN → Update
3. Pega el token nuevamente
4. Ejecuta el build otra vez

### Problema: Terraform falla con "403 Access Denied"
**Solución**:
```powershell
# Verificar credenciales AWS
aws sts get-caller-identity

# Si falla, reconfigurar:
aws configure

# Verificar que las credenciales en Jenkins sean correctas
```

### Problema: Tests fallan en el pipeline
**Solución**:
```powershell
# Ejecutar tests localmente para ver el error
npm test

# Verificar que todas las dependencias estén instaladas
npm install

# Ver logs detallados
npm test -- --verbose
```

### Problema: No puedo acceder a los servicios (localhost:XXXX)
**Solución**:
```powershell
# Verificar que los contenedores estén corriendo
docker-compose ps

# Verificar puertos
netstat -ano | findstr "8080"
netstat -ano | findstr "9000"
netstat -ano | findstr "3000"

# Si hay conflicto de puertos, edita docker-compose.yml
```

### Problema: Grafana no muestra métricas de AWS
**Solución**:
1. Verifica que hayas ejecutado `terraform apply` (necesitas recursos reales en AWS)
2. Verifica credenciales AWS en Grafana Data Source
3. Espera 5-10 minutos después del apply (CloudWatch tarda en reportar)
4. Ejecuta las Lambdas para generar métricas:
```powershell
aws lambda invoke --function-name elmundo-fitness-dev-access-control response.json
```

---

## 📚 Archivos de Referencia

- **RESUMEN_FINAL.md**: Resumen completo del proyecto
- **SONARQUBE_README.md**: Documentación detallada de SonarQube
- **GRAFANA_README.md**: Documentación detallada de Grafana
- **COMANDOS_UTILES.md**: Lista de comandos útiles
- **QUICK_START.md**: Inicio rápido del proyecto

---

## 🎯 Próximos Pasos

Una vez completada la configuración:

1. **Desarrollo**: Modifica los archivos Lambda en `lambda-code-examples/`
2. **Testing**: Añade más tests en `tests/`
3. **Deploy**: Ejecuta el pipeline con ACTION=apply
4. **Monitor**: Revisa métricas en Grafana y CloudWatch
5. **Quality**: Revisa análisis de SonarQube regularmente

---

## 💡 Consejos Finales

✅ **Backup de credenciales**: Guarda tus AWS keys en un lugar seguro
✅ **Costos AWS**: Revisa tu AWS Billing Dashboard regularmente
✅ **Git commits**: Haz commits frecuentes de tus cambios
✅ **Documentación**: Actualiza los README con tus cambios
✅ **Tests**: Escribe tests para cada nueva función Lambda
✅ **Security**: Nunca hagas commit de credenciales en Git
✅ **Destroy**: Cuando termines, ejecuta `terraform destroy` para eliminar recursos

---

## 🆘 Soporte

Si encuentras problemas:
1. Revisa la sección de **Troubleshooting** arriba
2. Revisa los logs de Docker: `docker-compose logs [servicio]`
3. Revisa Console Output de Jenkins
4. Revisa documentación de AWS: https://docs.aws.amazon.com/

---

## ✨ ¡Listo!

Tu entorno está completamente configurado. Ahora puedes:
- 🔨 Desarrollar funciones Lambda
- 🧪 Ejecutar tests automatizados
- 🔍 Analizar calidad de código
- 🚀 Desplegar a AWS automáticamente
- 📊 Monitorear con Grafana

**¡Happy coding! 🎉**
