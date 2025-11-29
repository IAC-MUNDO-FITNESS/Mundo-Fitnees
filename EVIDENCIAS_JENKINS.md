
# 📋 GUÍA DE EVIDENCIAS - JENKINS LABORATORIO
## El Mundo Fitness - Infraestructura AWS con Terraform

---

## 📌 **INFORMACIÓN DEL PROYECTO**

- **Proyecto:** El Mundo Fitness - Gimnasio Management System
- **Tecnologías:** Jenkins, Terraform, AWS, Docker, Grafana
- **Repositorio:** https://github.com/francoalessandro/iac-elmundo-fitness
- **Fecha de entrega:** 28 de noviembre de 2025

---

## 1️⃣ **JENKINS CONFIGURATION AS CODE**

### ✅ Archivo de configuración: `jenkins.yaml`

**Ubicación:** `C:\Users\franc\Downloads\IAC VALVERDE\jenkins.yaml`

**Configuración incluye:**
- Sistema de seguridad con usuario admin
- Configuración de agentes Docker
- Credenciales AWS y GitHub
- Job automático para el proyecto
- Herramientas instaladas (Git, Terraform)
- Configuración de build retention

**Captura requerida:**
- Screenshot del archivo `jenkins.yaml` completo
- Screenshot de Jenkins mostrando la configuración cargada

---

## 2️⃣ **PLUGINS INSTALADOS**

### 📦 Plugins necesarios para el proyecto:

#### **Plugins Core:**
1. **Git Plugin** - Integración con repositorios Git
2. **Pipeline Plugin** - Soporte para Jenkinsfile declarativo
3. **Credentials Binding Plugin** - Manejo de credenciales
4. **Timestamper Plugin** - Timestamps en logs

#### **Plugins de Infraestructura:**
5. **Terraform Plugin** - Ejecución de Terraform
6. **AWS Steps Plugin** - Comandos AWS CLI
7. **Docker Plugin** - Agentes Docker dinámicos
8. **Docker Pipeline Plugin** - Comandos Docker en Pipeline

#### **Plugins de Utilidades:**
9. **Configuration as Code Plugin (JCasC)** - jenkins.yaml
10. **Job DSL Plugin** - Creación de jobs programática
11. **Build Timeout Plugin** - Timeouts automáticos
12. **AnsiColor Plugin** - Colores en consola

### 🔧 **Cómo instalar:**

```bash
# Método 1: Jenkins UI
Manage Jenkins > Manage Plugins > Available > Buscar e instalar

# Método 2: Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin git
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin pipeline-model-definition
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin terraform
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin aws-credentials
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin docker-plugin
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin docker-workflow
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin configuration-as-code
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin job-dsl
```

### 📸 **Capturas requeridas:**
- [ ] Screenshot de **Manage Jenkins > Manage Plugins > Installed**
- [ ] Screenshot mostrando los 12 plugins instalados
- [ ] Screenshot de la versión de cada plugin crítico

---

## 3️⃣ **PIPELINE EJECUTÁNDOSE CON AGENTE**

### 🎯 Jenkinsfile - Stages y Agentes:

| Stage | Agente | Descripción |
|-------|--------|-------------|
| 1. Checkout | `any` | Clonar repositorio Git |
| 2. Validate Terraform | `docker` | Validar sintaxis Terraform |
| 3. Plan Infrastructure | `docker` | Terraform plan |
| 4. Manual Approval | N/A | Aprobación manual |
| 5. Apply Infrastructure | `docker` | Terraform apply |
| 6. Verify Deployment | `docker` | Verificar recursos AWS |
| 7. Start Grafana | `any` | Iniciar contenedor Grafana |
| 8. Notification | `any` | Notificar resultado |

### 🚀 **Ejecutar el Pipeline:**

```powershell
# 1. Acceder a Jenkins
Start-Process "http://localhost:8080"

# 2. Ir al job: elmundo-fitness-infrastructure

# 3. Click en "Build with Parameters"
#    - ENVIRONMENT: dev
#    - AUTO_APPROVE: true
#    - AWS_REGION: us-east-1

# 4. Click "Build"
```

### 📸 **Capturas requeridas:**
- [ ] Screenshot del **Blue Ocean Pipeline** mostrando todos los stages
- [ ] Screenshot de **Console Output** mostrando el agente asignado (ejemplo: `Running on docker-agent-xyz`)
- [ ] Screenshot de cada stage expandido mostrando logs
- [ ] Screenshot del **Stage View** con tiempos de ejecución
- [ ] Screenshot de la aprobación manual (Stage 4)

**Evidencia del agente:**
```
[Pipeline] stage
[Pipeline] { (Validate Terraform)
[Pipeline] node
Running on docker-agent-abc123 in /home/jenkins/agent/workspace/elmundo-fitness-infrastructure
[Pipeline] {
...
```

---

## 4️⃣ **CONEXIÓN A CLOUD (AWS)**

### ☁️ Configuración de credenciales AWS:

#### **En Jenkins UI:**
1. `Manage Jenkins > Manage Credentials`
2. `(global) > Add Credentials`
3. Tipo: `Username with password`
   - ID: `aws-credentials`
   - Username: `[AWS_ACCESS_KEY_ID]`
   - Password: `[AWS_SECRET_ACCESS_KEY]`
   - Description: `AWS Credentials for Terraform`

#### **En jenkins.yaml:**
```yaml
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              scope: GLOBAL
              id: "aws-credentials"
              username: "${AWS_ACCESS_KEY_ID}"
              password: "${AWS_SECRET_ACCESS_KEY}"
```

### ✅ **Verificar conexión:**

```powershell
# En el Pipeline, agregar stage de prueba:
stage('Test AWS Connection') {
    steps {
        withCredentials([
            usernamePassword(
                credentialsId: 'aws-credentials',
                usernameVariable: 'AWS_ACCESS_KEY_ID',
                passwordVariable: 'AWS_SECRET_ACCESS_KEY'
            )
        ]) {
            sh 'aws sts get-caller-identity'
            sh 'aws s3 ls'
        }
    }
}
```

### 📸 **Capturas requeridas:**
- [ ] Screenshot de **Manage Credentials** mostrando `aws-credentials`
- [ ] Screenshot del **Console Output** con resultado de `aws sts get-caller-identity`
- [ ] Screenshot mostrando recursos AWS creados (Console AWS)
- [ ] Screenshot de Terraform state en S3 bucket

**Ejemplo de output esperado:**
```json
{
    "UserId": "AIDAI...",
    "Account": "367622938780",
    "Arn": "arn:aws:iam::367622938780:user/jenkins"
}
```

---

## 5️⃣ **URL DEL REPOSITORIO**

### 📂 Repositorio GitHub:

**URL:** `https://github.com/francoalessandro/iac-elmundo-fitness`

**Estructura del repositorio:**
```
iac-elmundo-fitness/
├── Jenkinsfile                 # Pipeline definition
├── jenkins.yaml                # JCasC configuration
├── main.tf                     # Terraform orchestrator
├── variables.tf                # Variables definition
├── outputs.tf                  # Outputs definition
├── backend.tf                  # Remote state config
├── docker-compose.yml          # Grafana setup
├── GRAFANA_README.md          # Grafana documentation
├── EVIDENCIAS_JENKINS.md      # Este documento
├── modules/
│   ├── vpc/                   # VPC module
│   ├── dynamodb/              # DynamoDB module
│   ├── s3/                    # S3 module
│   ├── lambda/                # Lambda module
│   ├── api-gateway/           # API Gateway module
│   ├── cognito/               # Cognito module
│   ├── cloudfront/            # CloudFront module
│   ├── waf/                   # WAF module
│   ├── ses/                   # SES module
│   └── cloudwatch/            # CloudWatch module
├── environments/
│   └── dev/
│       └── terraform.tfvars   # Dev variables
└── grafana/
    ├── provisioning/
    │   ├── datasources/
    │   └── dashboards/
    └── dashboards/
```

### 📸 **Capturas requeridas:**
- [ ] Screenshot del repositorio en GitHub mostrando estructura
- [ ] Screenshot del último commit
- [ ] Screenshot de la sección "Insights" mostrando contribuciones
- [ ] Screenshot del archivo Jenkinsfile en GitHub

---

## 🎯 **CHECKLIST DE EVIDENCIAS PARA PDF**

### ✅ Configuración:
- [ ] Archivo `jenkins.yaml` completo (código)
- [ ] Screenshot de Jenkins con configuración cargada

### ✅ Plugins:
- [ ] Lista completa de 12 plugins requeridos
- [ ] Screenshot de "Manage Plugins > Installed"
- [ ] Screenshot de versiones de plugins

### ✅ Pipeline y Agentes:
- [ ] Screenshot de Blue Ocean Pipeline completo
- [ ] Screenshot de Console Output con agente Docker
- [ ] Screenshot de Stage View con tiempos
- [ ] Screenshot de cada stage (8 stages)
- [ ] Screenshot de aprobación manual

### ✅ Conexión AWS:
- [ ] Screenshot de credenciales en Jenkins
- [ ] Screenshot de `aws sts get-caller-identity`
- [ ] Screenshot de recursos en AWS Console
- [ ] Screenshot de Terraform state en S3

### ✅ Repositorio:
- [ ] URL del repositorio
- [ ] Screenshot de estructura en GitHub
- [ ] Screenshot de commits recientes
- [ ] Screenshot del Jenkinsfile

---

## 📄 **ESTRUCTURA DEL PDF**

```
PORTADA
  - Título: "Laboratorio Jenkins - El Mundo Fitness"
  - Nombre del estudiante
  - Fecha de entrega
  - Logo/imagen del proyecto

1. INTRODUCCIÓN
  - Descripción del proyecto
  - Arquitectura general (diagrama)
  - Tecnologías utilizadas

2. JENKINS CONFIGURATION AS CODE
  - Explicación de jenkins.yaml
  - Código completo
  - Screenshot de Jenkins

3. PLUGINS INSTALADOS
  - Tabla con plugins y descripciones
  - Screenshots de plugins instalados
  - Justificación de cada plugin

4. PIPELINE Y AGENTES
  - Explicación del Jenkinsfile
  - Tabla de stages y agentes
  - Screenshots de ejecución
  - Logs relevantes

5. CONEXIÓN A AWS
  - Configuración de credenciales
  - Screenshots de conexión exitosa
  - Recursos creados en AWS

6. REPOSITORIO GITHUB
  - URL y estructura
  - Screenshots del repositorio
  - Commits importantes

7. CONCLUSIONES
  - Aprendizajes
  - Desafíos enfrentados
  - Resultados obtenidos

ANEXOS
  - Código completo del Jenkinsfile
  - Código completo de jenkins.yaml
  - Outputs de Terraform
```

---

## 🚀 **CÓMO GENERAR LAS EVIDENCIAS**

### Paso 1: Configurar Jenkins
```powershell
# Iniciar Jenkins
java -jar jenkins.war --httpPort=8080

# O si usas Docker:
docker run -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
```

### Paso 2: Cargar configuración
```powershell
# Copiar jenkins.yaml a Jenkins
$JENKINS_HOME = "$env:USERPROFILE\.jenkins"
Copy-Item jenkins.yaml "$JENKINS_HOME\jenkins.yaml"

# Reiniciar Jenkins
# Manage Jenkins > Configuration as Code > Reload existing configuration
```

### Paso 3: Ejecutar Pipeline
```powershell
# Trigger el build manualmente
# O vía CLI:
java -jar jenkins-cli.jar -s http://localhost:8080/ build elmundo-fitness-infrastructure -p ENVIRONMENT=dev -p AUTO_APPROVE=true
```

### Paso 4: Capturar screenshots
```powershell
# Usar Snipping Tool o:
Win + Shift + S

# O PowerShell:
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("^{PRTSC}")
```

### Paso 5: Compilar PDF
```powershell
# Opción 1: Word/Google Docs
# - Pegar screenshots
# - Exportar como PDF

# Opción 2: Markdown to PDF
pandoc EVIDENCIAS_JENKINS.md -o EVIDENCIAS_JENKINS.pdf --toc

# Opción 3: LaTeX
pdflatex evidencias.tex
```

---

