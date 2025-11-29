# ============================================
# SCRIPT: INSTALAR PLUGINS EN JENKINS (PowerShell)
# ============================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Instalando Plugins en Jenkins" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Configuración
$JENKINS_URL = "http://localhost:8080"
$JENKINS_USER = "admin"
$JENKINS_PASSWORD = "ElMundoFitness2024!"

# Esperar a que Jenkins esté disponible
Write-Host ""
Write-Host "⏳ Esperando a que Jenkins esté disponible..." -ForegroundColor Yellow

do {
    try {
        $response = Invoke-WebRequest -Uri "$JENKINS_URL/login" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            break
        }
    }
    catch {
        Write-Host "   Esperando a Jenkins..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
} while ($true)

Write-Host "✅ Jenkins está disponible" -ForegroundColor Green

# Descargar Jenkins CLI
Write-Host ""
Write-Host "📥 Descargando Jenkins CLI..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -OutFile "jenkins-cli.jar"
Write-Host "✅ Jenkins CLI descargado" -ForegroundColor Green

# Lista de plugins a instalar
$plugins = @(
    "git",
    "workflow-aggregator",
    "pipeline-stage-view",
    "credentials-binding",
    "timestamper",
    "terraform",
    "aws-credentials",
    "aws-java-sdk",
    "docker-plugin",
    "docker-workflow",
    "configuration-as-code",
    "job-dsl",
    "build-timeout",
    "ansicolor",
    "blueocean",
    "email-ext",
    "slack",
    "github",
    "junit"
)

# Instalar cada plugin
Write-Host ""
Write-Host "📦 Instalando plugins..." -ForegroundColor Yellow

foreach ($plugin in $plugins) {
    Write-Host "   Instalando $plugin..." -ForegroundColor Gray
    java -jar jenkins-cli.jar -s $JENKINS_URL -auth "${JENKINS_USER}:${JENKINS_PASSWORD}" install-plugin $plugin
}

# Reiniciar Jenkins
Write-Host ""
Write-Host "🔄 Reiniciando Jenkins..." -ForegroundColor Yellow
java -jar jenkins-cli.jar -s $JENKINS_URL -auth "${JENKINS_USER}:${JENKINS_PASSWORD}" safe-restart

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ Plugins instalados exitosamente" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Jenkins se está reiniciando" -ForegroundColor Yellow
Write-Host "   Espera 30-60 segundos y accede a: $JENKINS_URL" -ForegroundColor White
Write-Host ""
