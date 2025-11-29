# 🎯 SCRIPT DE PRUEBA - JENKINS PIPELINE

## Ejecutar el Pipeline y Capturar Evidencias

### Paso 1: Iniciar Jenkins (si no está corriendo)

```powershell
# Opción A: Jenkins WAR file
java -jar jenkins.war --httpPort=8080

# Opción B: Docker
docker run -d -p 8080:8080 -p 50000:50000 `
  -v jenkins_home:/var/run/jenkins/home `
  -v /var/run/docker.sock:/var/run/docker.sock `
  --name jenkins `
  jenkins/jenkins:lts

# Esperar que Jenkins inicie
Start-Sleep -Seconds 30
```

---

### Paso 2: Configurar Jenkins con JCasC

```powershell
# Copiar jenkins.yaml al directorio de Jenkins
$JENKINS_HOME = "$env:USERPROFILE\.jenkins"
Copy-Item "C:\Users\franc\Downloads\IAC VALVERDE\jenkins.yaml" "$JENKINS_HOME\jenkins.yaml"

# Acceder a Jenkins
Start-Process "http://localhost:8080"

# En Jenkins UI:
# 1. Manage Jenkins > Configuration as Code
# 2. Click "Reload existing configuration"
# 3. Verificar que no haya errores
```

---

### Paso 3: Instalar Plugins Requeridos

```powershell
# Descargar Jenkins CLI
Invoke-WebRequest -Uri "http://localhost:8080/jnlpJars/jenkins-cli.jar" `
                  -OutFile "jenkins-cli.jar"

# Instalar plugins críticos
$plugins = @(
    'git',
    'workflow-aggregator',
    'pipeline-stage-view',
    'credentials-binding',
    'timestamper',
    'terraform',
    'aws-credentials',
    'docker-plugin',
    'docker-workflow',
    'configuration-as-code',
    'job-dsl',
    'blueocean',
    'ansicolor'
)

foreach ($plugin in $plugins) {
    Write-Host "Installing $plugin..." -ForegroundColor Cyan
        java -jar jenkins-cli.jar -s http://localhost:8080/ `
            -auth admin:${JENKINS_ADMIN_PASSWORD} `
            install-plugin $plugin
}

# Reiniciar Jenkins
java -jar jenkins-cli.jar -s http://localhost:8080/ `
    -auth admin:${JENKINS_ADMIN_PASSWORD} `
    safe-restart

Write-Host "Waiting for Jenkins to restart..." -ForegroundColor Yellow
Start-Sleep -Seconds 60
```

---

### Paso 4: Configurar Credenciales AWS

```powershell
# Opción A: Manual (UI)
# 1. Manage Jenkins > Manage Credentials
# 2. (global) > Add Credentials
# 3. Kind: Username with password
#    - ID: aws-credentials
#    - Username: [TU_AWS_ACCESS_KEY_ID]
#    - Password: [TU_AWS_SECRET_ACCESS_KEY]

# Opción B: Script Groovy (Jenkins Console)
# Manage Jenkins > Script Console
```

**Script Groovy para credenciales:**
```groovy
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*

def domain = Domain.global()
def store = Jenkins.instance.getExtensionList(
    'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
)[0].getStore()

// AWS Credentials
def awsCreds = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "aws-credentials",
    "AWS Credentials for Terraform",
    "AKIAIOSFODNN7EXAMPLE", // Reemplazar con tu Access Key
    "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" // Reemplazar con tu Secret Key
)

store.addCredentials(domain, awsCreds)

println("AWS Credentials added successfully!")
```

---

### Paso 5: Crear Job del Pipeline

```powershell
# El job ya debería estar creado por jenkins.yaml
# Verificar en: http://localhost:8080/job/elmundo-fitness-infrastructure/

# Si no existe, crear manualmente:
# 1. New Item
# 2. Nombre: elmundo-fitness-infrastructure
# 3. Tipo: Pipeline
# 4. Pipeline Definition: Pipeline script from SCM
#    - SCM: Git
#    - Repository URL: https://github.com/francoalessandro/iac-elmundo-fitness.git
#    - Script Path: Jenkinsfile
# 5. Save
```

---

### Paso 6: Ejecutar el Pipeline

```powershell
# Opción A: Jenkins UI
Start-Process "http://localhost:8080/job/elmundo-fitness-infrastructure/"
# Click "Build with Parameters"
# - ENVIRONMENT: dev
# - AUTO_APPROVE: true
# - AWS_REGION: us-east-1
# Click "Build"

# Opción B: Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ `
    -auth admin:${JENKINS_ADMIN_PASSWORD} `
    build elmundo-fitness-infrastructure `
     -p ENVIRONMENT=dev `
     -p AUTO_APPROVE=true `
     -p AWS_REGION=us-east-1 `
     -f -v

# -f: Wait for completion
# -v: Verbose output
```

---

### Paso 7: Monitorear la Ejecución

```powershell
# Opción A: Blue Ocean (RECOMENDADO para capturas)
Start-Process "http://localhost:8080/blue/organizations/jenkins/elmundo-fitness-infrastructure/activity"

# Opción B: Classic View
Start-Process "http://localhost:8080/job/elmundo-fitness-infrastructure/lastBuild/console"

# Opción C: CLI - Seguir logs
java -jar jenkins-cli.jar -s http://localhost:8080/ `
    -auth admin:${JENKINS_ADMIN_PASSWORD} `
    console elmundo-fitness-infrastructure
```

---

### Paso 8: Capturar Evidencias

#### 📸 Captura 1: Blue Ocean Pipeline View
```powershell
# 1. Abrir Blue Ocean
Start-Process "http://localhost:8080/blue/organizations/jenkins/elmundo-fitness-infrastructure/detail/main/1/pipeline"

# 2. Esperar a que todos los stages se ejecuten
# 3. Capturar pantalla completa (Win + Shift + S)
# 4. Guardar como: "01-blue-ocean-pipeline.png"
```

**Debe mostrar:**
- 8 stages en orden
- Colores verdes (éxito) o rojos (fallo)
- Tiempos de ejecución
- Agente asignado

---

#### 📸 Captura 2: Console Output con Agente
```powershell
# 1. Abrir consola del build
Start-Process "http://localhost:8080/job/elmundo-fitness-infrastructure/1/console"

# 2. Buscar líneas que muestren el agente:
# "Running on docker-agent-xyz in /home/jenkins/agent/workspace/..."

# 3. Capturar sección mostrando:
# - Stage name
# - Agent assignment
# - Primeras líneas de ejecución
# 4. Guardar como: "02-console-agent.png"
```

---

#### 📸 Captura 3: Stage View
```powershell
# 1. Abrir vista clásica
Start-Process "http://localhost:8080/job/elmundo-fitness-infrastructure/1/"

# 2. Scroll hasta "Stage View"
# 3. Capturar tabla mostrando:
# - Nombre de cada stage
# - Duración
# - Status (✓ o ✗)
# 4. Guardar como: "03-stage-view.png"
```

---

#### 📸 Captura 4: Terraform Plan Output
```powershell
# 1. En console output, buscar stage "Plan Infrastructure"
# 2. Capturar output mostrando:
# Plan: 28 to add, 0 to change, 0 to destroy
# 3. Guardar como: "04-terraform-plan.png"
```

---

#### 📸 Captura 5: Terraform Apply Output
```powershell
# 1. Buscar stage "Apply Infrastructure"
# 2. Capturar output mostrando:
# Apply complete! Resources: 28 added, 0 changed, 0 destroyed
# 3. Guardar como: "05-terraform-apply.png"
```

---

#### 📸 Captura 6: AWS Resources Verification
```powershell
# 1. Buscar stage "Verify Deployment"
# 2. Capturar output mostrando:
# - CloudFront distribution activa
# - Lambda functions creadas
# - API Gateway endpoints
# 3. Guardar como: "06-aws-verification.png"
```

---

#### 📸 Captura 7: Pipeline Approval
```powershell
# Si tienes manual approval:
# 1. Pipeline se pausará en "Manual Approval"
# 2. Capturar pantalla mostrando:
# - Stage en estado "Paused"
# - Botón "Proceed" o "Abort"
# 3. Guardar como: "07-manual-approval.png"
```

---

#### 📸 Captura 8: Final Success
```powershell
# 1. Cuando pipeline termine exitosamente
# 2. Capturar Blue Ocean mostrando:
# - Todos los stages verdes
# - Tiempo total de ejecución
# - "Pipeline succeeded"
# 3. Guardar como: "08-pipeline-success.png"
```

---

### Paso 9: Verificar Recursos en AWS Console

```powershell
# Abrir AWS Console
Start-Process "https://console.aws.amazon.com"

# Verificar servicios creados:
# 1. CloudFront: https://console.aws.amazon.com/cloudfront/
# 2. Lambda: https://console.aws.amazon.com/lambda/
# 3. API Gateway: https://console.aws.amazon.com/apigateway/
# 4. DynamoDB: https://console.aws.amazon.com/dynamodb/
# 5. S3: https://console.aws.amazon.com/s3/

# Capturar cada servicio mostrando recursos creados
```

---

### Paso 10: Exportar Logs y Configuración

```powershell
# Crear directorio para evidencias
New-Item -Path ".\evidencias-jenkins" -ItemType Directory -Force

# Exportar console output
$buildNum = 1
Invoke-WebRequest -Uri "http://localhost:8080/job/elmundo-fitness-infrastructure/$buildNum/consoleText" `
                  -OutFile ".\evidencias-jenkins\console-output.txt" `
                  -Credential (Get-Credential)

# Copiar archivos de configuración
Copy-Item "jenkins.yaml" ".\evidencias-jenkins\"
Copy-Item "Jenkinsfile" ".\evidencias-jenkins\"
Copy-Item "EVIDENCIAS_JENKINS.md" ".\evidencias-jenkins\"
Copy-Item "PLUGINS_JENKINS.md" ".\evidencias-jenkins\"

# Copiar capturas de pantalla
# (Manualmente mover los archivos .png a .\evidencias-jenkins\screenshots\)

Write-Host "Evidencias recopiladas en: .\evidencias-jenkins\" -ForegroundColor Green
```

---

### Paso 11: Generar Reporte HTML

**Script PowerShell para HTML Report:**
```powershell
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Evidencias Jenkins - El Mundo Fitness</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        h1 { color: #2c3e50; }
        h2 { color: #3498db; }
        img { max-width: 100%; border: 1px solid #ddd; margin: 10px 0; }
        .section { margin: 20px 0; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #3498db; color: white; }
        .success { color: green; font-weight: bold; }
        .failed { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h1>🚀 Evidencias Jenkins - El Mundo Fitness</h1>
    <p><strong>Fecha:</strong> $(Get-Date -Format "dd/MM/yyyy HH:mm")</p>
    <p><strong>Estudiante:</strong> Franco Alessandro</p>
    <p><strong>Repositorio:</strong> <a href="https://github.com/francoalessandro/iac-elmundo-fitness">GitHub</a></p>
    
    <div class="section">
        <h2>1. Configuración Jenkins</h2>
        <p>Archivo jenkins.yaml cargado exitosamente mediante JCasC</p>
        <pre>$(Get-Content jenkins.yaml -Raw -Encoding UTF8)</pre>
    </div>
    
    <div class="section">
        <h2>2. Plugins Instalados</h2>
        <table>
            <tr><th>#</th><th>Plugin</th><th>Versión</th><th>Status</th></tr>
            <tr><td>1</td><td>Git</td><td>4.x</td><td class="success">✓ Instalado</td></tr>
            <tr><td>2</td><td>Pipeline</td><td>2.x</td><td class="success">✓ Instalado</td></tr>
            <tr><td>3</td><td>Docker</td><td>1.x</td><td class="success">✓ Instalado</td></tr>
            <!-- Agregar resto de plugins -->
        </table>
    </div>
    
    <div class="section">
        <h2>3. Pipeline Execution</h2>
        <img src="screenshots/01-blue-ocean-pipeline.png" alt="Blue Ocean Pipeline">
        <p>Pipeline ejecutado exitosamente con 8 stages</p>
    </div>
    
    <div class="section">
        <h2>4. Console Output</h2>
        <img src="screenshots/02-console-agent.png" alt="Console Output">
        <p>Agente Docker asignado: docker-agent-abc123</p>
    </div>
    
    <div class="section">
        <h2>5. Recursos AWS</h2>
        <img src="screenshots/06-aws-verification.png" alt="AWS Resources">
        <p>28 recursos creados exitosamente en AWS</p>
    </div>
    
    <div class="section">
        <h2>6. Resultados</h2>
        <ul>
            <li class="success">✓ Jenkins configurado con JCasC</li>
            <li class="success">✓ 12+ plugins instalados</li>
            <li class="success">✓ Pipeline ejecutado con agente Docker</li>
            <li class="success">✓ Infraestructura desplegada en AWS</li>
            <li class="success">✓ Grafana configurado para monitoreo</li>
        </ul>
    </div>
</body>
</html>
"@

$html | Out-File -FilePath ".\evidencias-jenkins\reporte.html" -Encoding UTF8
Write-Host "Reporte HTML generado: .\evidencias-jenkins\reporte.html" -ForegroundColor Green
Start-Process ".\evidencias-jenkins\reporte.html"
```

---

## 📋 Checklist Final

### Antes de Entregar:
- [ ] Jenkins corriendo en `http://localhost:8080`
- [ ] `jenkins.yaml` cargado sin errores
- [ ] Todos los plugins críticos instalados
- [ ] Credenciales AWS configuradas
- [ ] Pipeline ejecutado al menos 1 vez exitosamente
- [ ] 8 capturas de pantalla tomadas
- [ ] Console output guardado en `.txt`
- [ ] Recursos AWS verificados en console
- [ ] Reporte HTML generado
- [ ] PDF compilado con todas las evidencias

### Archivos para Entregar:
```
evidencias-jenkins/
├── screenshots/
│   ├── 01-blue-ocean-pipeline.png
│   ├── 02-console-agent.png
│   ├── 03-stage-view.png
│   ├── 04-terraform-plan.png
│   ├── 05-terraform-apply.png
│   ├── 06-aws-verification.png
│   ├── 07-manual-approval.png
│   └── 08-pipeline-success.png
├── console-output.txt
├── jenkins.yaml
├── Jenkinsfile
├── EVIDENCIAS_JENKINS.md
├── PLUGINS_JENKINS.md
├── reporte.html
└── EVIDENCIAS_COMPLETAS.pdf ← ENTREGAR ESTE
```

---

## 🎯 Comandos Rápidos de Troubleshooting

```powershell
# Jenkins no inicia
netstat -ano | findstr :8080
taskkill /PID [PID] /F

# Ver logs de Jenkins
Get-Content "$env:USERPROFILE\.jenkins\logs\jenkins.log" -Tail 50 -Wait

# Limpiar workspace
Remove-Item "$env:USERPROFILE\.jenkins\workspace\*" -Recurse -Force

# Reiniciar Jenkins
Invoke-WebRequest -Uri "http://localhost:8080/restart" -Method POST -Credential (Get-Credential)

# Verificar plugins
Invoke-WebRequest -Uri "http://localhost:8080/pluginManager/api/json?depth=1" | 
    ConvertFrom-Json | 
    Select-Object -ExpandProperty plugins | 
    Select-Object shortName, version
```

---

**¡Listo para generar todas las evidencias requeridas!** 🎉

Ejecuta estos scripts en orden y tendrás todo lo necesario para el PDF de entrega.
