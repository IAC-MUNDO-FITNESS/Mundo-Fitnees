# 🔍 SonarQube - Análisis de Calidad de Código

## 📋 Descripción

SonarQube está integrado en el proyecto para análisis continuo de calidad de código, detectando:
- 🐛 Bugs y vulnerabilidades
- 🔒 Problemas de seguridad
- 💡 Code smells
- 📊 Cobertura de tests
- 📈 Deuda técnica

## 🚀 Inicio Rápido

### 1. Levantar SonarQube

```powershell
# Iniciar todos los servicios (Jenkins, Grafana, SonarQube)
docker-compose up -d

# O solo SonarQube y su base de datos
docker-compose up -d sonarqube sonarqube-db
```

### 2. Acceder a SonarQube

**URL:** http://localhost:9000

**Credenciales iniciales:**
- **Usuario:** `admin`
- **Contraseña:** `admin`

⚠️ **IMPORTANTE:** Al primer acceso, SonarQube te pedirá cambiar la contraseña.

### 3. Generar Token de Autenticación

1. Ve a: **My Account** → **Security** → **Generate Tokens**
2. Nombre del token: `jenkins-elmundo-fitness`
3. Tipo: `Global Analysis Token`
4. Copia el token generado

### 4. Configurar Token en Jenkins

1. Abre Jenkins: http://localhost:8080
2. Ve a: **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
3. Click **Add Credentials**:
   - **Kind:** Secret text
   - **Secret:** [Pega el token de SonarQube]
   - **ID:** `SONARQUBE_TOKEN`
   - **Description:** SonarQube Analysis Token

## 🔧 Integración con Pipeline

El Jenkinsfile ya incluye un stage de SonarQube:

```groovy
stage('SonarQube Analysis') {
    // Ejecuta análisis automático con:
    // - Análisis de JavaScript/Node.js
    // - Análisis de Terraform
    // - Reporte de cobertura de tests
}
```

### Análisis Automático

El pipeline ejecuta automáticamente:
1. Tests unitarios con Jest (genera cobertura)
2. SonarQube analiza el código
3. Genera reporte en: http://localhost:9000

## 📊 Análisis Manual

También puedes ejecutar análisis manualmente:

```powershell
# Usando Docker (recomendado)
docker run --rm `
    --network elmundo-fitness-monitoring `
    -e SONAR_HOST_URL="http://sonarqube:9000" `
    -e SONAR_LOGIN="<TU_TOKEN_AQUI>" `
    -v "${PWD}:/usr/src" `
    sonarsource/sonar-scanner-cli
```

## 📁 Configuración del Proyecto

El archivo `sonar-project.properties` contiene:

```properties
sonar.projectKey=elmundo-fitness
sonar.projectName=El Mundo Fitness - IAC
sonar.sources=.
sonar.exclusions=**/node_modules/**,**/.terraform/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

## 🔍 Métricas Analizadas

### JavaScript/Node.js
- ✅ Código Lambda functions
- ✅ Tests unitarios
- ✅ Cobertura de código
- ✅ Complejidad ciclomática
- ✅ Duplicación de código

### Terraform
- ✅ Configuración de infraestructura
- ✅ Buenas prácticas IaC
- ✅ Seguridad en recursos AWS

## 📈 Umbrales de Calidad (Quality Gates)

SonarQube valida automáticamente:

| Métrica | Umbral |
|---------|--------|
| Cobertura de código | ≥ 70% |
| Duplicación | ≤ 3% |
| Bugs | 0 (A) |
| Vulnerabilidades | 0 (A) |
| Code Smells | Rating A |
| Security Hotspots | 100% revisados |

## 🐳 Servicios Docker

### SonarQube Server
- **Container:** `elmundo-fitness-sonarqube`
- **Puerto:** 9000
- **Imagen:** `sonarqube:lts-community`
- **Volúmenes:**
  - `sonarqube-data`: Datos del proyecto
  - `sonarqube-extensions`: Plugins
  - `sonarqube-logs`: Logs

### PostgreSQL Database
- **Container:** `elmundo-fitness-sonarqube-db`
- **Puerto:** 5432 (interno)
- **Imagen:** `postgres:15-alpine`
- **Database:** `sonar`
- **Usuario:** `sonar`

## 🔧 Comandos Útiles

```powershell
# Ver logs de SonarQube
docker logs -f elmundo-fitness-sonarqube

# Ver logs de la base de datos
docker logs -f elmundo-fitness-sonarqube-db

# Verificar salud de SonarQube
curl http://localhost:9000/api/system/status

# Reiniciar SonarQube
docker-compose restart sonarqube

# Detener SonarQube
docker-compose stop sonarqube sonarqube-db

# Eliminar datos (reset completo)
docker-compose down
docker volume rm elmundo-fitness-sonarqube-data
docker volume rm elmundo-fitness-sonarqube-db-data
```

## 🌐 URLs Importantes

- **SonarQube Dashboard:** http://localhost:9000
- **Jenkins:** http://localhost:8080
- **Grafana:** http://localhost:3000
- **SonarQube API:** http://localhost:9000/api/system/status

## 📚 Plugins Incluidos

El contenedor `sonarqube:lts-community` incluye:
- ✅ JavaScript/TypeScript analyzer
- ✅ HTML analyzer
- ✅ JSON analyzer
- ✅ YAML analyzer

## ⚙️ Configuración Avanzada

### Configurar Webhooks (Opcional)

Para notificar a Jenkins cuando el análisis finaliza:

1. En SonarQube: **Administration** → **Configuration** → **Webhooks**
2. Create webhook:
   - **Name:** Jenkins
   - **URL:** http://jenkins:8080/sonarqube-webhook/
   - **Secret:** (opcional)

### Configurar Quality Gates Personalizados

1. **Administration** → **Quality Gates**
2. Create o modificar gates según necesidades del proyecto

## 🆘 Troubleshooting

### SonarQube no inicia

```powershell
# Verificar logs
docker logs elmundo-fitness-sonarqube

# Verificar que PostgreSQL está corriendo
docker ps | findstr sonarqube-db

# Aumentar límites del sistema (si es necesario)
# Editar docker-compose.yml y ajustar ulimits
```

### Error de conexión con base de datos

```powershell
# Verificar red Docker
docker network inspect elmundo-fitness-monitoring

# Reiniciar servicios en orden
docker-compose stop sonarqube
docker-compose up -d sonarqube-db
# Esperar 10 segundos
docker-compose up -d sonarqube
```

### Análisis falla en Jenkins

1. Verificar que el token está configurado en Jenkins credentials
2. Verificar que SonarQube está accesible desde Jenkins:
   ```bash
   docker exec elmundo-fitness-jenkins curl -f http://sonarqube:9000/api/system/status
   ```

## 📖 Documentación Oficial

- [SonarQube Documentation](https://docs.sonarqube.org/latest/)
- [SonarScanner for JavaScript](https://docs.sonarqube.org/latest/analysis/languages/javascript/)
- [Quality Gates](https://docs.sonarqube.org/latest/user-guide/quality-gates/)

## 🎯 Próximos Pasos

1. ✅ Levantar SonarQube: `docker-compose up -d`
2. ✅ Cambiar contraseña default
3. ✅ Generar token
4. ✅ Configurar token en Jenkins
5. ✅ Ejecutar pipeline en Jenkins
6. 📊 Ver resultados en http://localhost:9000

---

**Proyecto:** El Mundo Fitness - Infrastructure as Code  
**Stack:** SonarQube + PostgreSQL + Jenkins + Docker
