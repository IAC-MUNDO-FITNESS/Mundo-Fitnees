# ============================================
# GUÍA COMPLETA: JENKINS CON TESTS Y DEPLOYMENT
# ============================================

## 🎯 OVERVIEW DEL PIPELINE COMPLETO

Este pipeline ahora incluye:
1. ✅ **Checkout** - Descargar código del repositorio
2. ✅ **Unit Tests** - Tests unitarios con Node.js
3. ✅ **Security Scan** - Checkov para validar seguridad de Terraform
4. ✅ **Terraform Init** - Inicializar Terraform
5. ✅ **Terraform Validate** - Validar configuración
6. ✅ **Terraform Plan** - Generar plan de cambios
7. ✅ **Terraform Apply** - Aplicar cambios (con aprobación)
8. ✅ **Deploy to Dev** - Verificar deployment en ambiente dev
9. ✅ **Show Outputs** - Mostrar outputs de Terraform

---

## 📦 AGENTES CONFIGURADOS

### 1. Agente Docker Principal
- **Label**: `docker-agent`
- **Uso**: Stages de Terraform, checkout, deployment
- **Configuración**: Docker socket montado para ejecutar contenedores

### 2. Agente Node.js
- **Imagen**: `node:18-alpine`
- **Uso**: Ejecutar tests unitarios
- **Configuración**: `reuseNode: true` para mantener workspace

### 3. Agente Checkov
- **Imagen**: `bridgecrew/checkov:latest`
- **Uso**: Security scanning de Terraform
- **Configuración**: `reuseNode: true`

---

## 🧪 TESTS UNITARIOS

### Archivos de Tests
```
tests/
├── access-control.test.js           # Tests para control de acceso
├── notification-service.test.js     # Tests para notificaciones
└── subscription-control.test.js     # Tests para subscripciones
```

### Ejecutar Tests Localmente

```bash
# Instalar dependencias
npm install

# Ejecutar tests
npm test

# Ejecutar tests en modo watch
npm run test:watch

# Ejecutar tests para CI
npm run test:ci
```

### Coverage Requirements
- **Branches**: 70%
- **Functions**: 70%
- **Lines**: 70%
- **Statements**: 70%

---

## 🚀 CÓMO EJECUTAR EL PIPELINE

### Opción 1: Plan (sin cambios)
```
1. Ve a Jenkins: http://localhost:8080
2. Selecciona el job de tu proyecto
3. Click "Build with Parameters"
4. Configura:
   - ACTION: plan
   - ENVIRONMENT: dev
   - AWS_CREDENTIALS_ID: aws-elmundo-fitness
   - AWS_REGION: us-east-1
   - AUTO_APPROVE: false
5. Click "Build"
```

### Opción 2: Apply (aplicar cambios)
```
1. Mismos pasos que arriba
2. Cambia ACTION a: apply
3. Los tests se ejecutarán primero
4. Si los tests pasan, se ejecutará Terraform
5. Deberás aprobar manualmente antes de apply
6. Después del apply, se verificará el deployment en dev
```

### Opción 3: Destroy (eliminar recursos)
```
1. Mismos pasos que arriba
2. Cambia ACTION a: destroy
3. Deberás aprobar manualmente antes de destroy
```

---

## 📊 FLUJO DEL PIPELINE

```
┌─────────────────────┐
│   1. Checkout       │
│   (docker-agent)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   2. Unit Tests     │
│   (node:18-alpine)  │  ◄── Si falla, el pipeline se detiene aquí
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 3. Security Scan    │
│   (checkov)         │  ◄── Soft-fail, continúa aunque falle
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 4. Setup Terraform  │
│   (docker-agent)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 5. Terraform Init   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 6. Terraform Valid  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 7. Terraform Plan   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 8. Approval         │  ◄── Manual (si AUTO_APPROVE=false)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 9. Terraform Apply  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 10. Deploy to Dev   │  ◄── Solo para ENVIRONMENT=dev
│   (Verificación)    │
└─────────────────────┘
```

---

## 🔍 VERIFICACIÓN DE DEPLOYMENT

El stage "Deploy to Dev" verifica automáticamente:

### Lambda Functions
- `elmundo-fitness-dev-subscription-control`
- `elmundo-fitness-dev-access-control`
- `elmundo-fitness-dev-notification-service`

### DynamoDB Tables
- `elmundo-fitness-usuarios-dev`
- `elmundo-fitness-historial-asistencia-dev`

### API Gateway
- API REST para el ambiente dev
- URL del endpoint

---

## 📈 REPORTES Y ARTEFACTOS

El pipeline genera y archiva:

### Tests
- ✅ Reporte de tests en formato JUnit (`coverage/junit.xml`)
- ✅ Coverage report (`coverage/`)
- ✅ Coverage summary JSON

### Terraform
- ✅ Plan file (`tfplan`)
- ✅ State files (`terraform.tfstate`, `terraform.tfstate.backup`)
- ✅ Outputs JSON (`outputs.json`)

### Acceder a los reportes
```
1. Ve a Jenkins
2. Selecciona el build específico
3. Click en "Test Results" para ver tests
4. Click en "Artifacts" para ver archivos generados
```

---

## 🛠️ TROUBLESHOOTING

### Tests fallan
```bash
# Verificar tests localmente
npm install
npm test

# Ver logs detallados
npm test -- --verbose

# Ejecutar test específico
npm test -- access-control.test.js
```

### Agente Node.js no se conecta
```bash
# Verificar que Docker puede ejecutar contenedores
docker run --rm node:18-alpine node --version

# Ver logs de Jenkins
docker-compose logs -f jenkins
```

### Terraform falla
```bash
# Verificar credenciales AWS
# En Jenkins: Manage Jenkins → Credentials
# Verifica que 'aws-elmundo-fitness' existe

# Verificar región
# Asegúrate de que AWS_REGION esté correcto
```

---

## 🔐 SEGURIDAD

### Checkov Scan
El stage de Checkov verifica:
- ✅ Encriptación de datos en reposo
- ✅ Políticas de acceso IAM
- ✅ Configuraciones de red seguras
- ✅ Logging y monitoreo habilitados
- ✅ Backups configurados

**Nota**: Checkov está en modo `soft-fail`, no detiene el pipeline si encuentra issues.

---

## 📝 SIGUIENTE PASOS

### Para mejorar aún más:
1. **Agregar stage de integración** - Tests de integración
2. **Agregar stage de smoke tests** - Tests básicos post-deployment
3. **Agregar notificaciones** - Slack/Email cuando falla el pipeline
4. **Agregar métricas** - Enviar métricas de pipeline a CloudWatch
5. **Agregar stage de rollback** - Rollback automático si falla deployment

---

## 📚 DOCUMENTACIÓN ADICIONAL

- [Guía original](GUIA_COMPLETAR_TAREA.md)
- [Comandos útiles](COMANDOS_UTILES.md)
- [Plugins Jenkins](PLUGINS_JENKINS.md)
- [Instrucciones Jenkins](INSTRUCCIONES_JENKINS_ACTUALIZADO.md)
- [Grafana README](GRAFANA_README.md)

---

## ✅ CHECKLIST FINAL

- [x] Tests unitarios implementados
- [x] Agente Node.js configurado
- [x] Agente Checkov configurado
- [x] Stage de tests integrado
- [x] Stage de security scan integrado
- [x] Stage de deployment a dev integrado
- [x] Reportes de tests configurados
- [x] Verificación de recursos AWS post-deployment
- [x] Documentación completa

**¡Tu pipeline está completo! 🎉**
