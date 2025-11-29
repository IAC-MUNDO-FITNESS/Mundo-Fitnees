# ============================================
# INSTRUCCIONES - GRAFANA CON DOCKER
# Monitoreo de CloudWatch Logs para El Mundo Fitness
# ============================================

## 📋 Prerrequisitos

1. **Docker Desktop** instalado y corriendo
2. **Credenciales de AWS** con permisos para CloudWatch Logs
3. **Infraestructura desplegada** (Terraform apply ejecutado)

## 🚀 Inicio Rápido

### 1. Configurar Credenciales de AWS

Crear archivo `.env` en la raíz del proyecto:

```bash
# .env
AWS_ACCESS_KEY_ID=tu_access_key_aqui
AWS_SECRET_ACCESS_KEY=tu_secret_key_aqui
AWS_REGION=us-east-1
```

**IMPORTANTE**: No commitear este archivo al repositorio (ya está en `.gitignore`)

### 2. Iniciar Grafana

```powershell
# Desde la raíz del proyecto
cd "c:\Users\franc\Downloads\IAC VALVERDE"

# Iniciar container
docker-compose up -d

# Ver logs
docker-compose logs -f grafana
```

### 3. Acceder a Grafana

- **URL**: http://localhost:3000
- **Usuario**: `admin`
- **Contraseña**: `ElMundoFitness2024!` (cambiar en producción)

### 4. Verificar Datasource

1. Ir a **Configuration** → **Data Sources**
2. Verificar que `AWS CloudWatch - El Mundo Fitness` esté configurado
3. Hacer click en **Test** para validar conexión

### 5. Ver Dashboard

1. Ir a **Dashboards** → **Browse**
2. Abrir `El Mundo Fitness - Lambda Monitoring`
3. Ver métricas en tiempo real:
   - Invocations
   - Errors
   - Duration
   - Recent Errors (logs)

## 📊 Dashboards Disponibles

### Lambda Monitoring
- **Invocations**: Cantidad de ejecuciones de Lambda
- **Errors**: Errores en las funciones
- **Duration**: Tiempo de ejecución promedio
- **Recent Errors**: Últimos 50 errores de los logs

## 🔧 Comandos Útiles

```powershell
# Ver estado de containers
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f grafana

# Reiniciar Grafana
docker-compose restart grafana

# Detener todo
docker-compose down

# Detener y eliminar volúmenes (reset completo)
docker-compose down -v

# Actualizar imagen de Grafana
docker-compose pull grafana
docker-compose up -d grafana
```

## 🔐 Permisos IAM Necesarios

El usuario de AWS necesita estos permisos para CloudWatch:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:DescribeAlarms",
        "cloudwatch:GetMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "logs:DescribeLogGroups",
        "logs:GetLogEvents",
        "logs:FilterLogEvents",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:GetQueryResults"
      ],
      "Resource": "*"
    }
  ]
}
```

## 📈 Personalizar Dashboards

### Agregar Nuevas Queries

1. Editar dashboard existente
2. Agregar panel
3. Seleccionar datasource `AWS CloudWatch`
4. Elegir entre:
   - **Metrics**: Para gráficos numéricos (invocations, errors, duration)
   - **Logs**: Para búsquedas en logs con CloudWatch Insights

### Ejemplo: Query de Logs

```sql
fields @timestamp, @message, @requestId
| filter @message like /payment_success/
| stats count(*) as total by bin(5m)
```

### Ejemplo: Métrica Personalizada

- Namespace: `el-mundo-fitness-dev/Lambda`
- Metric: `SubscriptionErrors`
- Statistic: Sum
- Period: 5 minutes

## 🐛 Troubleshooting

### Error: "Access denied to CloudWatch"

**Solución**: Verificar credenciales en `.env` y permisos IAM

```powershell
# Probar credenciales con AWS CLI
aws cloudwatch list-metrics --namespace AWS/Lambda --region us-east-1
```

### Error: "No data points"

**Posibles causas**:
1. Infraestructura no desplegada → Ejecutar `terraform apply`
2. Lambda no se ha ejecutado → Hacer requests a la API
3. Time range incorrecto → Cambiar a "Last 6 hours" o "Last 24 hours"

### Container no inicia

```powershell
# Ver logs de error
docker-compose logs grafana

# Verificar puerto 3000 libre
netstat -ano | findstr :3000

# Recrear container
docker-compose down
docker-compose up -d
```

## 🔄 Integración con Jenkins

El Jenkinsfile incluye un stage para iniciar Grafana automáticamente:

```groovy
stage('Start Grafana') {
    steps {
        powershell '''
            cd "${WORKSPACE}"
            docker-compose up -d grafana
        '''
    }
}
```

## 💾 Backup de Dashboards

Los dashboards se guardan automáticamente en el volumen `grafana-data`. Para hacer backup manual:

```powershell
# Exportar dashboard
docker exec elmundo-fitness-grafana grafana-cli admin export-dashboard "elmundo-fitness-lambda" > backup-dashboard.json

# Copiar volumen completo
docker run --rm -v elmundo-fitness-grafana-data:/data -v ${PWD}:/backup alpine tar czf /backup/grafana-backup.tar.gz /data
```

## 🌐 Acceso Remoto (Opcional)

Para acceder a Grafana desde otra máquina:

1. **Opción 1: Port Forwarding**
```powershell
# Cambiar puerto en docker-compose.yml
ports:
  - "8080:3000"  # Ahora accesible en http://IP:8080
```

2. **Opción 2: Nginx Reverse Proxy**
```nginx
server {
    listen 80;
    server_name grafana.elmundofitness.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }
}
```

## 📚 Recursos

- [Grafana CloudWatch Datasource Docs](https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/)
- [CloudWatch Logs Insights Query Syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)
- [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/best-practices/best-practices-for-creating-dashboards/)

## 🔒 Seguridad en Producción

⚠️ **ANTES DE PRODUCCIÓN**:

1. Cambiar credenciales de admin en `.env`:
```bash
GF_SECURITY_ADMIN_PASSWORD=tu_password_segura_aqui
```

2. Usar IAM Roles en lugar de Access Keys (si está en EC2/ECS)

3. Habilitar HTTPS con certificado SSL

4. Configurar autenticación OAuth/LDAP

5. Limitar acceso por IP en Security Group

---

**Última actualización**: 2024
**Versión Grafana**: latest (10.x)
**Compatibilidad**: Docker Desktop para Windows
