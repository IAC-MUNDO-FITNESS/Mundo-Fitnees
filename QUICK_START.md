# ⚡ QUICK START - Pipeline Completo

## ✅ VERIFICACIÓN RÁPIDA

```powershell
# ¿Tienes todos los archivos?
dir tests\*.test.js        # Debe mostrar 3 archivos
dir package.json           # Debe existir
dir Jenkinsfile           # Debe existir
```

## 🚀 INICIO RÁPIDO (3 PASOS)

### 1️⃣ Inicia Docker Desktop
```powershell
# Abre Docker Desktop desde el menú inicio
# Espera a que diga "Engine running"
```

### 2️⃣ Inicia Jenkins
```powershell
docker-compose up -d jenkins
docker-compose logs -f jenkins
# Espera el mensaje: "Jenkins is fully up and running"
# Ctrl+C para salir de los logs
```

### 3️⃣ Configura Jenkins
```
1. Abre: http://localhost:8080
2. Login: admin / ElMundoFitness2024!
3. New Item → Nombre: "Mundo-Fitness-Pipeline" → Pipeline → OK
4. En "Pipeline":
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: https://github.com/IAC-MUNDO-FITNESS/Mundo-Fitnees.git
   - Credentials: Add → Jenkins
     * Kind: Username with password
     * Username: tu-usuario-github
     * Password: tu-token-github
     * ID: github-credentials
   - Branch: */main
   - Script Path: Jenkinsfile
5. Save
6. "Build with Parameters" → ACTION: plan → Build
```

---

## 📋 CHECKLIST DE EJECUCIÓN

### Antes de Ejecutar
- [ ] Docker Desktop está corriendo
- [ ] Jenkins está corriendo (`docker ps` muestra jenkins)
- [ ] Tienes credenciales AWS configuradas en Jenkins
- [ ] El código está pusheado a GitHub

### Primera Ejecución (Plan)
- [ ] ACTION: **plan**
- [ ] ENVIRONMENT: **dev**
- [ ] AUTO_APPROVE: **false**
- [ ] Click "Build"

### Observa el Pipeline
- [ ] ✅ Checkout - Descarga código
- [ ] ✅ Unit Tests - Ejecuta tests (puede tardar ~2 min primera vez)
- [ ] ✅ Security Scan - Checkov
- [ ] ✅ Setup Terraform
- [ ] ✅ Terraform Init
- [ ] ✅ Terraform Validate
- [ ] ✅ Terraform Plan

### Segunda Ejecución (Apply)
- [ ] ACTION: **apply**
- [ ] Todos los stages anteriores pasan
- [ ] Apruebas manualmente el deployment
- [ ] ✅ Terraform Apply
- [ ] ✅ Deploy to Dev - Verifica recursos
- [ ] ✅ Show Outputs

---

## 🎯 EVIDENCIAS PARA LA TAREA

Captura pantallas de:

### 1. Plugins Instalados
```
Manage Jenkins → Plugins → Installed
Muestra los plugins principales:
- Pipeline
- Docker Plugin
- Git Plugin
- Configuration as Code
- AWS Credentials
```

### 2. Pipeline Ejecutándose
```
Dashboard → Mundo-Fitness-Pipeline → Build #1
Muestra:
- Stage View con todos los stages
- Console Output
- Tests Results
```

### 3. Agentes Docker
```
En Console Output debe verse:
- [node:18-alpine] (tests)
- [bridgecrew/checkov] (security scan)
- [docker-agent] (terraform)
```

### 4. URL del Repositorio
```
Mundo-Fitness-Pipeline → Configure
Muestra la sección SCM con:
- Repository URL
- Credentials configuradas
```

---

## 🐛 PROBLEMAS COMUNES

### "Docker daemon is not running"
```powershell
# Solución: Inicia Docker Desktop
# Verifica: docker ps
```

### "Tests failed"
```bash
# Verifica localmente:
npm install
npm test

# Si falla localmente, revisa:
# - node_modules instalados
# - package.json correcto
```

### "AWS credentials not found"
```
1. Manage Jenkins → Credentials
2. System → Global credentials
3. Add Credentials:
   - Kind: AWS Credentials
   - ID: aws-elmundo-fitness
   - Access Key ID: tu-access-key
   - Secret Access Key: tu-secret-key
```

### "Repository not found"
```
1. Verifica que el repo sea público O
2. Configura credentials de GitHub:
   - Kind: Username with password
   - Username: tu-usuario
   - Password: tu-personal-access-token
```

---

## 📊 ¿CÓMO SÉ QUE FUNCIONÓ?

### Tests Pasaron ✅
```
Console Output debe mostrar:
✓ Access Control Lambda Tests
✓ Notification Service Lambda Tests
✓ Subscription Control Lambda Tests

Test Suites: 3 passed, 3 total
Tests: XX passed, XX total
```

### Terraform Aplicó ✅
```
Console Output debe mostrar:
Apply complete! Resources: XX added, 0 changed, 0 destroyed.

Outputs:
api_gateway_url = "https://xxx.execute-api.us-east-1.amazonaws.com/dev"
cloudfront_url = "https://xxx.cloudfront.net"
```

### Deploy Verificado ✅
```
Deploy to Dev debe mostrar:
Verificando Lambda Functions...
  - elmundo-fitness-dev-subscription-control: Active
  - elmundo-fitness-dev-access-control: Active
  - elmundo-fitness-dev-notification-service: Active

Verificando DynamoDB Tables...
  - elmundo-fitness-usuarios-dev: ACTIVE
  - elmundo-fitness-historial-asistencia-dev: ACTIVE

Verificando API Gateway...
  - API Gateway ID: abc123
  - API URL: https://abc123.execute-api.us-east-1.amazonaws.com/dev
```

---

## 🎉 SUCCESS!

Si ves todo lo anterior, tu pipeline está **COMPLETO Y FUNCIONAL**! 🚀

### Lee Más:
- `RESUMEN_FINAL.md` - Resumen ejecutivo completo
- `PIPELINE_COMPLETO.md` - Guía detallada
- `COMPLETADO.md` - Lista de implementaciones

---

**¡Buena suerte! 💪**
