# ✅ JENKINS FUNCIONANDO - INSTRUCCIONES ACTUALIZADAS

## 🎉 ¡PROBLEMA RESOLUIDO!

Jenkins estaba reiniciándose por conflictos con la configuración JCasC (Jenkins Configuration as Code) que requería plugins específicos que no estaban instalados.

**Solución aplicada:** Deshabilitamos temporalmente JCasC para que Jenkins inicie normalmente.

---

## 🚀 ACCEDER A JENKINS

### URL:
```
http://localhost:8080
```

### Primera vez - Configuración inicial:

1. **Abre tu navegador** en: http://localhost:8080

2. **Obten la contraseña inicial:**

```powershell
docker exec elmundo-fitness-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Si no existe ese archivo, intenta acceder directamente - puede que Jenkins ya esté configurado.

3. **Instalar Plugins Sugeridos:**
   - Cuando Jenkins pregunte, selecciona: **"Install suggested plugins"**
   - Espera a que se instalen (toma 5-10 minutos)

4. **Crear usuario Admin:**
   - Usuario: `admin`
   - Contraseña: `admin` (o la que prefieras)
   - Completa los demás campos

---

## 📦 PASO 1: INSTALAR PLUGINS ADICIONALES REQUERIDOS

Una vez dentro de Jenkins:

1. Ve a: **Manage Jenkins** → **Plugins** → **Available plugins**

2. Busca e instala estos plugins (marca el checkbox y dale "Install"):

**Plugins esenciales para la tarea:**
- [ ] **Docker Plugin** - Para agentes Docker
- [ ] **Docker Pipeline** - Para comandos Docker en Jenkinsfile
- [ ] **Blue Ocean** - UI moderna (importante para capturas bonitas)
- [ ] **Configuration as Code** - Para JCasC
- [ ] **AWS Credentials Plugin** - Credenciales AWS
- [ ] **Terraform Plugin** - Para Terraform

**Plugins ya incluidos en "suggested plugins":**
- ✅ Git Plugin
- ✅ Pipeline
- ✅ Credentials Binding
- ✅ GitHub Integration

3. Click en **"Install"** (abajo de la página)
4. Marca **"Restart Jenkins when installation is complete"**
5. Espera a que reinicie (2-3 minutos)

---

## 🐳 PASO 2: CONFIGURAR DOCKER CLOUD (AGENTES)

### 2.1 Configurar Docker Cloud

1. Ve a: **Manage Jenkins** → **Nodes** → **Clouds**
2. Click en **"New cloud"**
3. Nombre: `docker`
4. Tipo: **Docker**
5. Click **"Create"**

### 2.2 Configurar Docker Host

En la configuración de la cloud:

**Docker Host URI:**
```
tcp://host.docker.internal:2375
```
> ⚠️ **Nota para Windows:** Asegúrate de que Docker Desktop tenga habilitado:
> **Settings → General → "Expose daemon on tcp://localhost:2375 without TLS"**

**Click en "Test Connection"** - Debe mostrar: "Version = ..."

### 2.3 Agregar Docker Agent Template

Scroll hacia abajo a "Docker Agent templates" y click en **"Add Docker Template"**:

**Configuración del template:**
- **Labels:** `docker-agent`
- **Name:** `docker-agent`
- **Docker Image:** `jenkins/agent:latest`
- **Instance Capacity:** `4`
- **Remote File System Root:** `/home/jenkins/agent`

**Container settings:**
- **Connect method:** "Attach Docker container"
- **User:** `jenkins`

**Pull strategy:** "Pull once and update latest"

Click **"Save"**

### 2.4 📸 CAPTURA 2: Configuración de Cloud

**¡Captura esta pantalla!** Muestra la configuración del Docker cloud con el Docker Host URI y el template configurado.

---

## 🔧 PASO 3: CREAR EL JOB/PIPELINE

### 3.1 Crear un Nuevo Pipeline

1. En el Dashboard, click en **"New Item"**
2. Nombre: `elmundo-fitness-infrastructure`
3. Tipo: **Pipeline**
4. Click **"OK"**

### 3.2 Configurar el Pipeline

En la configuración del job:

**Description:**
```
Deploy El Mundo Fitness AWS Infrastructure using Terraform
```

**Build Triggers:**
- [ ] Poll SCM: `H/5 * * * *` (revisar cada 5 minutos)

**Pipeline:**
- **Definition:** `Pipeline script from SCM`
- **SCM:** `Git`
- **Repository URL:** `https://github.com/TU_USUARIO/iac-elmundo-fitness.git`
  > ⚠️ Reemplaza con la URL de TU repositorio GitHub
- **Branch Specifier:** `*/main`
- **Script Path:** `Jenkinsfile`

Click **"Save"**

### 3.3 📸 CAPTURA 4: URL del Repositorio

**¡Captura esta pantalla!** Muestra la configuración del Pipeline con la URL del repositorio.

---

## 🎯 PASO 4: EJECUTAR EL PIPELINE

### 4.1 Crear un Jenkinsfile Simple

Para probar el agente Docker, crea este archivo en tu repositorio:

**Jenkinsfile** (en la raíz de tu repositorio):
```groovy
pipeline {
    agent {
        label 'docker-agent'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Código clonado correctamente'
                sh 'pwd'
                sh 'ls -la'
            }
        }
        
        stage('Environment Info') {
            steps {
                echo 'Verificando entorno de ejecución'
                sh 'whoami'
                sh 'uname -a'
            }
        }
        
        stage('Terraform Version') {
            steps {
                script {
                    docker.image('hashicorp/terraform:latest').inside {
                        sh 'terraform version'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completado'
        }
        success {
            echo '✅ Pipeline exitoso!'
        }
        failure {
            echo '❌ Pipeline falló'
        }
    }
}
```

### 4.2 Ejecutar el Build

1. Ve al job **elmundo-fitness-infrastructure**
2. Click en **"Build Now"**
3. Observa cómo se ejecuta

### 4.3 Ver en Blue Ocean

1. Click en **"Open Blue Ocean"** (menú lateral izquierdo)
2. Verás una interfaz moderna con los stages del pipeline
3. **📸 CAPTURA 3: ¡Captura esta pantalla!** Debe mostrar el pipeline ejecutándose con los stages

---

## 📸 RESUMEN DE CAPTURAS NECESARIAS

### ✅ Captura 1: Plugins Instalados
- **Ubicación:** Manage Jenkins → Plugins → Installed plugins
- **Debe mostrar:** Lista de plugins instalados incluyendo Docker Plugin, Blue Ocean, etc.

### ✅ Captura 2: Configuración de Docker Cloud
- **Ubicación:** Manage Jenkins → Clouds → docker (configuration)
- **Debe mostrar:** Docker Host URI y Docker Agent Template configurado

### ✅ Captura 3: Pipeline Ejecutándose
- **Ubicación:** Blue Ocean view del pipeline
- **Debe mostrar:** Stages del pipeline ejecutándose o completados, usando el agente Docker

### ✅ Captura 4: URL del Repositorio
- **Ubicación:** Job Configuration → Pipeline section
- **Debe mostrar:** Definition = "Pipeline script from SCM", SCM = "Git", Repository URL

---

## 📄 ESTRUCTURA DEL DOCUMENTO PDF

### Portada
- Título: "Configuración de Jenkins con Docker Agents - El Mundo Fitness"
- Tu nombre completo
- Fecha: 28 de noviembre de 2025
- Curso/Asignatura

### 1. Introducción (1 página)
- Descripción del proyecto El Mundo Fitness
- Objetivos de la práctica
- Tecnologías utilizadas: Jenkins, Docker, Terraform, AWS

### 2. Jenkins Configuration as Code (1-2 páginas)
- ¿Qué es JCasC y para qué sirve?
- Ventajas de usar configuración como código
- Ejemplo de configuración (puedes incluir extractos del jenkins.yaml)

### 3. Instalación y Configuración de Plugins (2 páginas)
- **[Insertar CAPTURA 1]**
- Tabla de plugins instalados:

| Plugin | Versión | Propósito |
|--------|---------|-----------|
| Git Plugin | Latest | Integración con repositorios Git |
| Pipeline | Latest | Soporte para Jenkinsfile (CI/CD) |
| Docker Plugin | Latest | Provisionar agentes Docker dinámicos |
| Docker Pipeline | Latest | Ejecutar comandos Docker en pipeline |
| Blue Ocean | Latest | Interfaz moderna para visualizar pipelines |
| AWS Credentials | Latest | Manejo seguro de credenciales AWS |
| Terraform Plugin | Latest | Ejecutar comandos Terraform |
| Configuration as Code | Latest | Configurar Jenkins mediante YAML |

### 4. Configuración de Agentes Docker (2 páginas)
- **[Insertar CAPTURA 2]**
- Explicación de qué son los agentes Docker
- Ventajas:
  * Aislamiento de builds
  * Escalabilidad automática
  * Entornos reproducibles
  * No contamina el servidor Jenkins master
  * Fácil limpieza después de cada build
- Cómo funciona la integración Docker-Jenkins

### 5. Ejecución del Pipeline (2 páginas)
- **[Insertar CAPTURA 3]**
- Descripción de los stages del Jenkinsfile:
  * **Checkout:** Clona el código desde GitHub
  * **Environment Info:** Verifica el entorno de ejecución
  * **Terraform Version:** Ejecuta Terraform en contenedor
- Cómo el agente Docker ejecuta cada stage
- Logs y depuración

### 6. Integración con Repositorio Git (1-2 páginas)
- **[Insertar CAPTURA 4]**
- Flujo completo de CI/CD:
  1. Desarrollador hace push a GitHub
  2. Jenkins detecta cambios (polling)
  3. Jenkins clona el repositorio
  4. Jenkins ejecuta el Jenkinsfile
  5. Se provisiona un agente Docker
  6. Se ejecutan los stages del pipeline
  7. Resultados se reportan
- Beneficios del SCM integration
- Automatización del deployment

### 7. Conclusiones (1 página)
- Resumen de lo aprendido
- Importancia de CI/CD en proyectos modernos
- Ventajas de usar Jenkins + Docker + Terraform
- Aplicación práctica en el proyecto El Mundo Fitness
- Aprendizajes personales y dificultades superadas

### Referencias (opcional)
- https://www.jenkins.io/doc/
- https://plugins.jenkins.io/docker-plugin/
- https://www.jenkins.io/doc/book/blueocean/
- https://www.terraform.io/

---

## ⚠️ TROUBLESHOOTING

### Jenkins no responde
```powershell
docker compose logs jenkins
docker compose restart jenkins
```

### El agente Docker no se conecta
1. Verifica que Docker Desktop esté corriendo
2. En Docker Desktop: Settings → General → Activa "Expose daemon on tcp://localhost:2375"
3. En Jenkins Cloud config, usa: `tcp://host.docker.internal:2375`
4. Click en "Test Connection"

### El pipeline falla
- Verifica el Console Output del build
- Asegúrate de que el label del agente coincida: `docker-agent`
- Verifica que el Jenkinsfile esté en la raíz del repositorio

### No encuentro Blue Ocean
- Ve a: Manage Jenkins → Plugins
- Busca "Blue Ocean" e instala
- Reinicia Jenkins
- Aparecerá en el menú lateral izquierdo

---

## 📞 COMANDOS ÚTILES

```powershell
# Ver logs de Jenkins
docker compose logs -f jenkins

# Reiniciar Jenkins
docker compose restart jenkins

# Ver status
docker compose ps

# Acceder al contenedor
docker exec -it elmundo-fitness-jenkins bash

# Ver plugins instalados
docker exec elmundo-fitness-jenkins jenkins-plugin-cli --list

# Detener todo
docker compose down

# Iniciar todo
docker compose up -d
```

---

## ✅ CHECKLIST FINAL ANTES DE ENTREGAR

- [ ] Documento tiene portada con información personal
- [ ] Introducción clara del proyecto
- [ ] Explicación de Jenkins Configuration as Code
- [ ] CAPTURA 1: Plugins instalados (incluida y legible)
- [ ] Tabla completa de plugins con sus funciones
- [ ] CAPTURA 2: Configuración Docker Cloud (incluida y legible)
- [ ] Explicación detallada de agentes Docker y sus ventajas
- [ ] CAPTURA 3: Pipeline ejecutándose en Blue Ocean (incluida y legible)
- [ ] Descripción de stages del Jenkinsfile
- [ ] CAPTURA 4: URL del repositorio en configuración (incluida y legible)
- [ ] Explicación del flujo CI/CD completo
- [ ] Conclusiones personales y aprendizajes
- [ ] Documento exportado a PDF
- [ ] PDF tiene entre 8-12 páginas
- [ ] Todas las capturas son claras y profesionales
- [ ] Formato consistente y profesional

---

## 🎯 ¡ÉXITO!

Si sigues estos pasos, tendrás:
1. ✅ Jenkins funcionando correctamente
2. ✅ Plugins instalados
3. ✅ Agentes Docker configurados
4. ✅ Pipeline ejecutándose
5. ✅ Todas las capturas necesarias
6. ✅ Documento PDF completo

**¡Buena suerte con tu entrega! 🚀**
