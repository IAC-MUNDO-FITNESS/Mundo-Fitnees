# 📦 Lista de Plugins Requeridos para Jenkins

## Instalación Masiva de Plugins

### Método 1: Jenkins Plugin Manager (UI)
1. Accede a: `Manage Jenkins > Manage Plugins`
2. Tab `Available`
3. Busca e instala cada plugin de la lista
4. Reinicia Jenkins

### Método 2: Jenkins CLI
```bash
# Descargar Jenkins CLI
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

# Instalar todos los plugins
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:${JENKINS_ADMIN_PASSWORD} install-plugin \
  git \
  workflow-aggregator \
  pipeline-stage-view \
  credentials-binding \
  timestamper \
  terraform \
  aws-credentials \
  aws-java-sdk \
  docker-plugin \
  docker-workflow \
  configuration-as-code \
  job-dsl \
  build-timeout \
  ansicolor \
  blueocean \
  email-ext \
  slack \
  github \
  junit

# Reiniciar Jenkins
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:${JENKINS_ADMIN_PASSWORD} safe-restart
```

### Método 3: Script Groovy (Consola Jenkins)
```groovy
// Manage Jenkins > Script Console
def plugins = [
  'git',
  'workflow-aggregator',
  'pipeline-stage-view',
  'credentials-binding',
  'timestamper',
  'terraform',
  'aws-credentials',
  'aws-java-sdk',
  'docker-plugin',
  'docker-workflow',
  'configuration-as-code',
  'job-dsl',
  'build-timeout',
  'ansicolor',
  'blueocean',
  'email-ext',
  'slack',
  'github',
  'junit'
]

def pm = Jenkins.instance.pluginManager
def uc = Jenkins.instance.updateCenter
plugins.each { pluginName ->
  if (!pm.getPlugin(pluginName)) {
    println("Installing ${pluginName}")
    def plugin = uc.getPlugin(pluginName)
    plugin.deploy()
  } else {
    println("${pluginName} already installed")
  }
}

Jenkins.instance.save()
println("Plugins installation complete. Restart Jenkins to activate.")
```

---

## 📋 Lista Detallada de Plugins

### 1. **Git Plugin** (`git`)
- **Versión mínima:** 4.x
- **Propósito:** Integración con repositorios Git
- **Uso:** Clonar código desde GitHub/GitLab
- **Configuración:** Automática con `jenkins.yaml`

### 2. **Pipeline Plugin** (`workflow-aggregator`)
- **Versión mínima:** 2.x
- **Propósito:** Soporte para Jenkinsfile declarativo e imperativo
- **Uso:** Ejecutar pipelines definidos en código
- **Dependencias:** Incluye varios sub-plugins (pipeline-model-definition, pipeline-groovy, etc.)

### 3. **Pipeline: Stage View** (`pipeline-stage-view`)
- **Versión mínima:** 2.x
- **Propósito:** Vista gráfica de stages del pipeline
- **Uso:** Visualizar progreso de cada stage
- **Importante para:** Captura de evidencias

### 4. **Credentials Binding Plugin** (`credentials-binding`)
- **Versión mínima:** 1.x
- **Propósito:** Inyectar credenciales en el build
- **Uso:** Pasar AWS credentials a Terraform
- **Sintaxis:** `withCredentials([...])`

### 5. **Timestamper** (`timestamper`)
- **Versión mínima:** 1.x
- **Propósito:** Agregar timestamps a logs de consola
- **Uso:** Debugging y auditoría
- **Configuración:** `timestamps { ... }` en pipeline

### 6. **Terraform Plugin** (`terraform`)
- **Versión mínima:** 1.x
- **Propósito:** Ejecutar comandos Terraform
- **Uso:** `terraform init/plan/apply/destroy`
- **Configuración:** Define herramienta en `jenkins.yaml`

### 7. **AWS Credentials Plugin** (`aws-credentials`)
- **Versión mínima:** 1.x
- **Propósito:** Manejar credenciales AWS
- **Uso:** Autenticación con AWS services
- **Tipos:** Access Key/Secret Key, IAM Role, STS

### 8. **AWS Java SDK** (`aws-java-sdk`)
- **Versión mínima:** 1.x
- **Propósito:** SDK de AWS para plugins Jenkins
- **Uso:** Interacción con APIs de AWS
- **Requerido por:** aws-credentials, pipeline-aws

### 9. **Docker Plugin** (`docker-plugin`)
- **Versión mínima:** 1.x
- **Propósito:** Provisionar agentes Docker dinámicos
- **Uso:** Ejecutar stages en contenedores efímeros
- **Configuración:** Define cloud en `jenkins.yaml`

### 10. **Docker Pipeline** (`docker-workflow`)
- **Versión mínima:** 1.x
- **Propósito:** Comandos Docker en Jenkinsfile
- **Uso:** `docker.image().inside { ... }`
- **Ejemplo:**
```groovy
docker.image('hashicorp/terraform:1.6').inside {
    sh 'terraform version'
}
```

### 11. **Configuration as Code Plugin (JCasC)** (`configuration-as-code`)
- **Versión mínima:** 1.x
- **Propósito:** Configurar Jenkins mediante YAML
- **Uso:** Cargar `jenkins.yaml` automáticamente
- **Beneficios:** Infraestructura como código para Jenkins

### 12. **Job DSL Plugin** (`job-dsl`)
- **Versión mínima:** 1.x
- **Propósito:** Crear jobs mediante código Groovy
- **Uso:** Definir jobs en `jenkins.yaml`
- **Ejemplo:** Job de deployment automático

### 13. **Build Timeout Plugin** (`build-timeout`)
- **Versión mínima:** 1.x
- **Propósito:** Timeout automático para builds
- **Uso:** Prevenir builds colgados
- **Configuración:**
```groovy
options {
    timeout(time: 1, unit: 'HOURS')
}
```

### 14. **AnsiColor Plugin** (`ansicolor`)
- **Versión mínima:** 1.x
- **Propósito:** Colores ANSI en output de consola
- **Uso:** Mejorar legibilidad de logs
- **Configuración:**
```groovy
options {
    ansiColor('xterm')
}
```

### 15. **Blue Ocean** (`blueocean`)
- **Versión mínima:** 1.x
- **Propósito:** UI moderna para pipelines
- **Uso:** Visualización gráfica mejorada
- **Acceso:** `http://localhost:8080/blue`
- **⭐ Importante:** Mejor para capturas de evidencias

### 16. **Email Extension Plugin** (`email-ext`)
- **Versión mínima:** 2.x
- **Propósito:** Notificaciones por email avanzadas
- **Uso:** Alertas de builds fallidos/exitosos
- **Configuración:**
```groovy
post {
    failure {
        emailext subject: "Build Failed: ${env.JOB_NAME}",
                 body: "Check console output at ${env.BUILD_URL}",
                 to: "francoalessandro0306@gmail.com"
    }
}
```

### 17. **Slack Notification Plugin** (`slack`)
- **Versión mínima:** 2.x
- **Propósito:** Notificaciones a canal Slack
- **Uso:** Alertas a equipo de desarrollo
- **Opcional:** Si tienes workspace de Slack

### 18. **GitHub Plugin** (`github`)
- **Versión mínima:** 1.x
- **Propósito:** Integración avanzada con GitHub
- **Uso:** Webhooks, status checks, releases
- **Beneficios:** Trigger automático con commits

### 19. **JUnit Plugin** (`junit`)
- **Versión mínima:** 1.x
- **Propósito:** Reportes de pruebas unitarias
- **Uso:** `junit '**/test-results/*.xml'`
- **Opcional:** Si tienes tests automatizados

---

## 🔍 Verificación de Plugins Instalados

### PowerShell Script
```powershell
# Obtener lista de plugins instalados
$response = Invoke-RestMethod -Uri "http://localhost:8080/pluginManager/api/json?depth=1" `
                              -Method GET `
                              -Credential (Get-Credential)

$response.plugins | Select-Object shortName, version, active | 
    Sort-Object shortName | 
    Format-Table -AutoSize

# Exportar a CSV
$response.plugins | Select-Object shortName, version, active, longName | 
    Export-Csv -Path "jenkins-plugins.csv" -NoTypeInformation
```

### Curl (si tienes WSL o Git Bash)
```bash
curl -s -u admin:${JENKINS_ADMIN_PASSWORD} http://localhost:8080/pluginManager/api/json?depth=1 | \
  jq -r '.plugins[] | "\(.shortName):\(.version)"' | \
  sort
```

---

## 📸 Capturas Requeridas

### Vista de Plugins Instalados
1. `Manage Jenkins > Manage Plugins > Installed`
2. Scroll para mostrar todos los plugins
3. Captura con **Snipping Tool** (Win + Shift + S)

### Detalle de Plugin Individual
1. Click en plugin específico (ejemplo: `Configuration as Code`)
2. Captura mostrando:
   - Nombre completo
   - Versión instalada
   - Descripción
   - Dependencias

### Blue Ocean Dashboard
1. Accede a `http://localhost:8080/blue`
2. Captura la vista moderna del pipeline
3. Muestra stages coloreados (verde/rojo)

---

## 🐛 Troubleshooting

### Plugin no se instala
```groovy
// Script Console: Forzar actualización del Update Center
Jenkins.instance.updateCenter.updateAllSites()

// Verificar disponibilidad
def uc = Jenkins.instance.updateCenter
uc.sites.each { site ->
    println("Site: ${site.id}")
    site.updateDirectlyNow()
}
```

### Conflictos de versiones
```bash
# Ver dependencias de un plugin
java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins | grep terraform

# Actualizar todos los plugins
java -jar jenkins-cli.jar -s http://localhost:8080/ safe-restart
```

### Jenkins no inicia después de instalar plugins
```powershell
# Modo seguro (sin plugins)
java -jar jenkins.war --httpPort=8080 --disable-plugins

# Deshabilitar plugin problemático
Remove-Item "$env:USERPROFILE\.jenkins\plugins\[plugin-name]"
```

---

## 📊 Tabla Resumen para PDF

| # | Plugin | Versión | Propósito | Crítico |
|---|--------|---------|-----------|---------|
| 1 | Git | 4.x | Control de versiones | ✅ |
| 2 | Pipeline | 2.x | Jenkinsfile declarativo | ✅ |
| 3 | Stage View | 2.x | Vista de stages | ✅ |
| 4 | Credentials Binding | 1.x | Manejo de secrets | ✅ |
| 5 | Timestamper | 1.x | Timestamps en logs | ⭐ |
| 6 | Terraform | 1.x | IaC automation | ✅ |
| 7 | AWS Credentials | 1.x | Autenticación AWS | ✅ |
| 8 | AWS SDK | 1.x | AWS API calls | ✅ |
| 9 | Docker Plugin | 1.x | Agentes Docker | ✅ |
| 10 | Docker Workflow | 1.x | Docker en pipeline | ✅ |
| 11 | JCasC | 1.x | Configuration as Code | ✅ |
| 12 | Job DSL | 1.x | Jobs como código | ⭐ |
| 13 | Build Timeout | 1.x | Timeouts automáticos | ⭐ |
| 14 | AnsiColor | 1.x | Colores en consola | ⭐ |
| 15 | Blue Ocean | 1.x | UI moderna | ✅ |
| 16 | Email Extension | 2.x | Notificaciones email | ⭐ |
| 17 | Slack | 2.x | Notificaciones Slack | ⚪ |
| 18 | GitHub | 1.x | Integración GitHub | ⭐ |
| 19 | JUnit | 1.x | Test reports | ⚪ |

**Leyenda:**
- ✅ Crítico (sin él no funciona)
- ⭐ Importante (mejora funcionalidad)
- ⚪ Opcional (nice to have)

---

## 🎯 Checklist de Instalación

- [ ] Todos los plugins críticos (✅) instalados
- [ ] Jenkins reiniciado después de instalación
- [ ] No hay plugins con errores (rojo)
- [ ] Blue Ocean accesible en `/blue`
- [ ] JCasC puede cargar `jenkins.yaml`
- [ ] Docker plugin conecta a Docker daemon
- [ ] AWS credentials configuradas correctamente
- [ ] Terraform tool configurado
- [ ] Git puede clonar repositorios
- [ ] Pipeline puede ejecutar Jenkinsfile

---

**Última actualización:** 28 de noviembre de 2025
