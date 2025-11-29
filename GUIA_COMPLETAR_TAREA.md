# ============================================
# GUÍA: COMPLETAR TAREA DE JENKINS
# ============================================

## 📋 CHECKLIST DE LA TAREA

- [ ] 1. Configurar Jenkins con Jenkins Configuration as Code
- [ ] 2. Configurar agentes Docker para ejecutar pipelines
- [ ] 3. Instalar plugins necesarios mediante Managing Plugins
- [ ] 4. Generar evidencias en PDF con capturas de:
  - Plugins instalados
  - Pipeline ejecutándose con agente
  - Conexión a cloud (Docker)
  - URL del repositorio

---

## 🚀 PASO 1: INICIAR JENKINS

### 1.1 Configurar variables de entorno

Edita el archivo `.env` con tus credenciales reales:

```bash
# Abre el archivo .env
notepad .env
```

Reemplaza:
- `your_aws_access_key_here` con tu AWS Access Key
- `your_aws_secret_key_here` con tu AWS Secret Key  
- `your_github_token_here` con tu GitHub Personal Access Token

### 1.2 Iniciar Jenkins con Docker Compose

```bash
# Iniciar Jenkins
docker-compose up -d jenkins

# Ver logs (espera a que diga "Jenkins is fully up and running")
docker-compose logs -f jenkins
```

### 1.3 Acceder a Jenkins

Abre tu navegador en: **http://localhost:8080**

**Credenciales:**
- Usuario: `admin`
- Contraseña: `ElMundoFitness2024!` (o la que configuraste en `.env`)

---

## 📦 PASO 2: VERIFICAR PLUGINS INSTALADOS

### 2.1 Acceder a Manage Plugins

1. Ve a: **Manage Jenkins** → **Manage Plugins**
2. Click en la pestaña **Installed**
3. Verifica que estén instalados los siguientes plugins:

**Plugins Core:**
- ✅ Git Plugin
- ✅ Pipeline (workflow-aggregator)
- ✅ Pipeline: Stage View
- ✅ Credentials Binding Plugin
- ✅ Configuration as Code Plugin (JCasC)
- ✅ Job DSL Plugin

**Plugins Docker:**
- ✅ Docker Plugin
- ✅ Docker Pipeline

**Plugins AWS:**
- ✅ AWS Credentials Plugin
- ✅ AWS Java SDK

**Plugins Utilidad:**
- ✅ Terraform Plugin
- ✅ Timestamper
- ✅ AnsiColor
- ✅ Blue Ocean

### 2.2 Instalar plugins faltantes (si es necesario)

Si algún plugin no está instalado:

1. Ve a: **Manage Jenkins** → **Manage Plugins**
2. Click en la pestaña **Available**
3. Busca el plugin por nombre
4. Marca el checkbox
5. Click en **Install without restart**

### 2.3 📸 CAPTURA 1: PLUGINS INSTALADOS

**Captura requerida:**
- Pantalla de **Manage Plugins** → **Installed**
- Debe mostrar la lista de plugins instalados
- Asegúrate de que se vean los plugins principales listados arriba

---

## 🐳 PASO 3: VERIFICAR CONFIGURACIÓN DE CLOUD (DOCKER)

### 3.1 Acceder a Cloud Configuration

1. Ve a: **Manage Jenkins** → **Manage Nodes and Clouds**
2. Click en **Configure Clouds** (en el menú lateral izquierdo)
3. Deberías ver una cloud llamada **docker**

### 3.2 Verificar configuración del agente Docker

La configuración debe mostrar:
- **Name:** docker
- **Docker Host URI:** unix:///var/run/docker.sock
- **Docker Agent templates:**
  - Label: docker-agent
  - Docker Image: jenkins/agent:latest
  
### 3.3 📸 CAPTURA 2: CONFIGURACIÓN DE CLOUD

**Captura requerida:**
- Pantalla de **Configure Clouds**
- Debe mostrar la configuración del Docker cloud
- Asegúrate de que se vea el Docker Host URI y los templates

---

## 🔧 PASO 4: CREAR Y EJECUTAR UN JOB CON AGENTE

### 4.1 Verificar que el job ya existe

1. Ve a la página principal de Jenkins (Dashboard)
2. Deberías ver un job llamado: **elmundo-fitness-infrastructure**
3. Si no existe, lo crearemos manualmente

### 4.2 Si el job NO existe, créalo manualmente:

1. Click en **New Item**
2. Nombre: `elmundo-fitness-infrastructure`
3. Tipo: **Pipeline**
4. Click **OK**

En la configuración del Pipeline:
- **Definition:** Pipeline script from SCM
- **SCM:** Git
- **Repository URL:** `https://github.com/francoalessandro/iac-elmundo-fitness.git`
- **Branch:** `*/main`
- **Script Path:** `Jenkinsfile`

### 4.3 Ejecutar el Pipeline

1. Click en el job **elmundo-fitness-infrastructure**
2. Click en **Build Now**
3. Espera a que inicie la ejecución

### 4.4 📸 CAPTURA 3: PIPELINE EJECUTÁNDOSE CON AGENTE

**Captura requerida:**
- Vista del pipeline ejecutándose
- Debe mostrar los stages (Plan, Apply, etc.)
- Debe verse que está usando el agente Docker
- **TIP:** Usa Blue Ocean para mejor visualización: http://localhost:8080/blue

Para acceder a Blue Ocean:
1. Click en **Open Blue Ocean** (en el menú lateral)
2. Click en el pipeline que se está ejecutando
3. Captura la pantalla con los stages en ejecución

### 4.5 Ver logs del build

1. Click en el número del build (ej: #1)
2. Click en **Console Output**
3. Deberías ver líneas como:
   ```
   Running on docker-agent-xxxxx in /home/jenkins/agent/workspace/...
   ```

---

## 🔗 PASO 5: VERIFICAR CONEXIÓN AL REPOSITORIO

### 5.1 Ver configuración del Job

1. Ve al job **elmundo-fitness-infrastructure**
2. Click en **Configure**
3. Scroll hasta la sección **Pipeline**

### 5.2 📸 CAPTURA 4: URL DEL REPOSITORIO

**Captura requerida:**
- Configuración del Pipeline
- Debe mostrar:
  - **Definition:** Pipeline script from SCM
  - **SCM:** Git
  - **Repository URL:** La URL de tu repositorio
  - **Branch Specifier:** */main

---

## 📄 PASO 6: GENERAR DOCUMENTO PDF CON EVIDENCIAS

### 6.1 Crear documento en Word/Google Docs

Crea un documento con las siguientes secciones:

**Portada:**
- Título: "Configuración de Jenkins - El Mundo Fitness"
- Nombre del estudiante
- Fecha: 28 de noviembre de 2025
- Nombre del curso/laboratorio

**Contenido:**

1. **Introducción**
   - Breve descripción del proyecto
   - Objetivos de la configuración de Jenkins

2. **Configuración con Jenkins Configuration as Code (JCasC)**
   - Explicación de qué es JCasC
   - Captura del archivo `jenkins.yaml`
   - Explicación de las secciones principales

3. **Plugins Instalados**
   - Insertar **CAPTURA 1** (lista de plugins)
   - Tabla con plugins principales y su función:
   
   | Plugin | Función |
   |--------|---------|
   | Git | Integración con repositorios Git |
   | Pipeline | Soporte para Jenkinsfile |
   | Docker Plugin | Provisionar agentes Docker |
   | AWS Credentials | Manejo de credenciales AWS |
   | Terraform | Ejecutar comandos Terraform |
   | Blue Ocean | UI moderna para pipelines |

4. **Configuración de Agentes Docker**
   - Insertar **CAPTURA 2** (configuración de cloud)
   - Explicación de cómo funcionan los agentes dinámicos
   - Ventajas de usar Docker como agente

5. **Ejecución de Pipeline**
   - Insertar **CAPTURA 3** (pipeline ejecutándose)
   - Descripción de los stages del pipeline
   - Explicación de cómo el agente Docker ejecuta las tareas

6. **Conexión al Repositorio**
   - Insertar **CAPTURA 4** (URL del repositorio)
   - Explicación del flujo de CI/CD
   - Descripción del Jenkinsfile

7. **Conclusiones**
   - Resumen de lo configurado
   - Beneficios de usar Jenkins con Docker
   - Aprendizajes obtenidos

### 6.2 Exportar a PDF

- En Word: **Archivo** → **Guardar como** → **PDF**
- En Google Docs: **Archivo** → **Descargar** → **Documento PDF**

---

## 📋 CHECKLIST FINAL DE EVIDENCIAS

Verifica que tu PDF contenga:

- [ ] Portada con tu información
- [ ] Explicación de Jenkins Configuration as Code
- [ ] Código del archivo `jenkins.yaml`
- [ ] **CAPTURA 1:** Lista de plugins instalados
- [ ] Tabla explicando la función de cada plugin principal
- [ ] **CAPTURA 2:** Configuración de Docker Cloud
- [ ] Explicación de agentes Docker
- [ ] **CAPTURA 3:** Pipeline ejecutándose con agente Docker
- [ ] Descripción de los stages del pipeline
- [ ] **CAPTURA 4:** URL del repositorio Git
- [ ] Explicación del flujo CI/CD
- [ ] Conclusiones

---

## 🛠️ COMANDOS ÚTILES DURANTE LA TAREA

### Ver logs de Jenkins
```bash
docker-compose logs -f jenkins
```

### Reiniciar Jenkins
```bash
docker-compose restart jenkins
```

### Acceder a la consola de Jenkins (para debugging)
```bash
docker exec -it elmundo-fitness-jenkins bash
```

### Ver plugins instalados (desde CLI)
```bash
docker exec elmundo-fitness-jenkins jenkins-plugin-cli --list
```

### Ver archivo de configuración JCasC cargado
```bash
docker exec elmundo-fitness-jenkins cat /var/jenkins_home/casc_configs/jenkins.yaml
```

### Forzar recarga de configuración JCasC
1. Ve a: **Manage Jenkins** → **Configuration as Code**
2. Click en **Reload existing configuration**

---

## ⚠️ TROUBLESHOOTING

### Problema: Jenkins no carga la configuración JCasC

**Solución:**
```bash
# Verificar que el archivo esté montado correctamente
docker exec elmundo-fitness-jenkins ls -la /var/jenkins_home/casc_configs/

# Ver logs de JCasC
docker-compose logs jenkins | grep -i "casc"
```

### Problema: Los plugins no se instalan automáticamente

**Solución:**
Instalar manualmente desde la UI:
1. **Manage Jenkins** → **Manage Plugins** → **Available**
2. Buscar e instalar cada plugin de `plugins.txt`

### Problema: No puede conectar con Docker socket

**Solución (Windows):**
1. Asegúrate de que Docker Desktop esté corriendo
2. Ve a Docker Desktop Settings → General
3. Activa "Expose daemon on tcp://localhost:2375 without TLS"
4. Actualiza docker-compose.yml:
   ```yaml
   environment:
     - DOCKER_HOST=tcp://host.docker.internal:2375
   ```

### Problema: El agente Docker no se conecta

**Solución:**
1. Ve a **Manage Jenkins** → **Manage Nodes and Clouds** → **Configure Clouds**
2. Click en **Test Connection** en la configuración de Docker
3. Debe decir "Version = ..." (sin errores)

---

## 📚 RECURSOS ADICIONALES

- **Jenkins Documentation:** https://www.jenkins.io/doc/
- **JCasC Plugin:** https://github.com/jenkinsci/configuration-as-code-plugin
- **Docker Plugin:** https://plugins.jenkins.io/docker-plugin/
- **Blue Ocean:** https://www.jenkins.io/doc/book/blueocean/

---

## ✅ ENTREGA FINAL

Una vez completados todos los pasos:

1. Genera el PDF con todas las evidencias
2. Verifica que contenga las 4 capturas requeridas
3. Revisa que el documento sea claro y profesional
4. Entrega el PDF según las instrucciones de tu profesor

**¡Buena suerte! 🚀**
