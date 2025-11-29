# ============================================
# RESUMEN RÁPIDO - COMPLETAR TAREA JENKINS
# ============================================

## ✅ YA ESTÁ CONFIGURADO

1. ✅ Jenkins está corriendo en: **http://localhost:8080**
2. ✅ Jenkins Configuration as Code (JCasC) configurado
3. ✅ Agentes Docker configurados
4. ✅ Archivo de plugins preparado

**Credenciales de acceso:**
- Usuario: `admin`
- Contraseña: `admin` (o `ElMundoFitness2024!` si configuraste el .env)

---

## 📸 PASOS PARA COMPLETAR LA TAREA

### PASO 1: Acceder a Jenkins
```
http://localhost:8080
```
Login con: admin / admin

### PASO 2: Instalar Plugins

**Opción A - Instalar con Script (Recomendado):**
```powershell
# En PowerShell
.\install-plugins.ps1
```

**Opción B - Instalar Manualmente:**
1. Ve a: **Manage Jenkins** → **Manage Plugins** → **Available**
2. Busca e instala estos plugins:
   - Git Plugin
   - Pipeline (workflow-aggregator)
   - Docker Plugin
   - Docker Pipeline
   - Configuration as Code
   - Blue Ocean
   - AWS Credentials
   - Terraform Plugin

3. Click **Install without restart**

### PASO 3: Tomar las 4 Capturas Requeridas

#### 📸 CAPTURA 1: Plugins Instalados
1. Ve a: **Manage Jenkins** → **Manage Plugins** → **Installed**
2. Captura la pantalla mostrando los plugins instalados

#### 📸 CAPTURA 2: Configuración de Cloud (Docker)
1. Ve a: **Manage Jenkins** → **Manage Nodes and Clouds**
2. Click en **Configure Clouds**
3. Captura la configuración del Docker cloud

#### 📸 CAPTURA 3: Pipeline Ejecutándose con Agente
1. En el Dashboard, click en el job **elmundo-fitness-infrastructure**
   (Si no existe, créalo manualmente - ver GUIA_COMPLETAR_TAREA.md)
2. Click en **Build Now**
3. Click en **Open Blue Ocean** (menú lateral)
4. Captura el pipeline ejecutándose mostrando los stages

#### 📸 CAPTURA 4: URL del Repositorio
1. Click en el job **elmundo-fitness-infrastructure**
2. Click en **Configure**
3. Scroll a la sección **Pipeline**
4. Captura mostrando la URL del repositorio Git

---

## 📄 PASO 4: Crear el Documento PDF

### Estructura del Documento:

**1. Portada**
- Título del proyecto
- Tu nombre
- Fecha: 28 de noviembre de 2025
- Curso/Laboratorio

**2. Contenido (6-8 páginas):**

**Sección 1: Introducción**
- Descripción del proyecto El Mundo Fitness
- Objetivos de la configuración de Jenkins

**Sección 2: Jenkins Configuration as Code**
- Qué es JCasC y por qué es importante
- Fragmento del archivo `jenkins.yaml`
- Explicación de las secciones principales

**Sección 3: Plugins Instalados**
- **[Insertar CAPTURA 1]**
- Tabla con plugins y sus funciones:

| Plugin | Función |
|--------|---------|
| Git Plugin | Integración con repositorios Git |
| Pipeline | Soporte para Jenkinsfile (CI/CD) |
| Docker Plugin | Provisionar agentes dinámicos |
| Docker Pipeline | Ejecutar comandos Docker en pipeline |
| AWS Credentials | Manejo seguro de credenciales AWS |
| Terraform Plugin | Ejecutar comandos Terraform |
| Blue Ocean | Interfaz moderna para visualizar pipelines |
| Configuration as Code | Configuración de Jenkins mediante YAML |

**Sección 4: Configuración de Agentes Docker**
- **[Insertar CAPTURA 2]**
- Explicación de agentes Docker
- Ventajas:
  - Ejecución aislada de builds
  - Escalabilidad automática
  - Entornos reproducibles
  - No contamina el servidor Jenkins

**Sección 5: Ejecución del Pipeline**
- **[Insertar CAPTURA 3]**
- Descripción de los stages:
  - **Checkout:** Clonar código del repositorio
  - **Validate:** Validar sintaxis de Terraform
  - **Plan:** Generar plan de infraestructura
  - **Apply:** Aplicar cambios en AWS
- Cómo el agente Docker ejecuta cada stage

**Sección 6: Integración con Repositorio Git**
- **[Insertar CAPTURA 4]**
- Flujo de CI/CD:
  1. Código se actualiza en GitHub
  2. Jenkins detecta cambios (polling)
  3. Jenkins clona el repositorio
  4. Ejecuta el Jenkinsfile
  5. Despliega infraestructura en AWS
- Beneficios del SCM integration

**Sección 7: Conclusiones**
- Resumen de lo aprendido
- Beneficios de Jenkins + Docker + Terraform
- Importancia de Infrastructure as Code
- Aprendizajes personales

**3. Referencias** (opcional)
- https://www.jenkins.io/doc/
- https://github.com/jenkinsci/configuration-as-code-plugin
- https://plugins.jenkins.io/docker-plugin/

---

## ✅ CHECKLIST ANTES DE ENTREGAR

- [ ] Documento tiene portada con tu información
- [ ] Explicación clara de JCasC
- [ ] CAPTURA 1: Plugins instalados (incluida)
- [ ] Tabla explicando función de cada plugin
- [ ] CAPTURA 2: Configuración Docker Cloud (incluida)
- [ ] Explicación de agentes Docker
- [ ] CAPTURA 3: Pipeline ejecutándose (incluida)
- [ ] Descripción de stages del pipeline
- [ ] CAPTURA 4: URL del repositorio (incluida)
- [ ] Explicación del flujo CI/CD
- [ ] Conclusiones personales
- [ ] Documento exportado a PDF
- [ ] PDF tiene entre 6-10 páginas
- [ ] Todas las capturas son legibles

---

## 🆘 SI TIENES PROBLEMAS

### Jenkins no carga
```powershell
# Ver logs
docker compose logs jenkins

# Reiniciar
docker compose restart jenkins
```

### No puedo acceder a http://localhost:8080
```powershell
# Verificar que está corriendo
docker compose ps

# Ver puertos
docker port elmundo-fitness-jenkins
```

### Los plugins no aparecen
```powershell
# Recargar configuración JCasC
# En Jenkins: Manage Jenkins → Configuration as Code → Reload
```

### El pipeline falla
- Verifica que Docker esté corriendo
- Verifica que las credenciales AWS estén configuradas
- Revisa el Console Output del build

---

## 📞 COMANDOS ÚTILES

```powershell
# Ver logs en tiempo real
docker compose logs -f jenkins

# Reiniciar Jenkins
docker compose restart jenkins

# Detener Jenkins
docker compose stop jenkins

# Eliminar y recrear Jenkins
docker compose down jenkins
docker compose up -d jenkins

# Acceder al contenedor
docker exec -it elmundo-fitness-jenkins bash

# Ver plugins instalados desde CLI
docker exec elmundo-fitness-jenkins jenkins-plugin-cli --list
```

---

## 🎯 ARCHIVO DE EVIDENCIAS

Lee el archivo completo con todos los detalles:
**GUIA_COMPLETAR_TAREA.md**

¡Éxito en tu tarea! 🚀
