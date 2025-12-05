# ============================================
# Script: Verificar Pipeline Completo
# ============================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Verificando configuración del Pipeline" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar archivos esenciales
Write-Host "1. Verificando archivos esenciales..." -ForegroundColor Yellow

$requiredFiles = @(
    "Jenkinsfile",
    "package.json",
    "docker-compose.yml",
    "jenkins.yaml",
    "tests\access-control.test.js",
    "tests\notification-service.test.js",
    "tests\subscription-control.test.js",
    "lambda-code-examples\access-control.js",
    "lambda-code-examples\notification-service.js",
    "lambda-code-examples\subscription-control.js"
)

$allFilesPresent = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $file (FALTA)" -ForegroundColor Red
        $allFilesPresent = $false
    }
}
Write-Host ""

# Verificar Node.js instalado
Write-Host "2. Verificando Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    Write-Host "   ✓ Node.js instalado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ Node.js no encontrado (opcional para ejecución local)" -ForegroundColor Yellow
}
Write-Host ""

# Verificar Docker
Write-Host "3. Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    Write-Host "   ✓ Docker instalado: $dockerVersion" -ForegroundColor Green
    
    # Verificar que Docker esté corriendo
    docker ps > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Docker daemon corriendo" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Docker daemon no está corriendo" -ForegroundColor Red
        Write-Host "     Inicia Docker Desktop" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ✗ Docker no encontrado" -ForegroundColor Red
}
Write-Host ""

# Verificar Docker Compose
Write-Host "4. Verificando Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version 2>&1
    Write-Host "   ✓ Docker Compose instalado: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Docker Compose no encontrado" -ForegroundColor Red
}
Write-Host ""

# Verificar Jenkins
Write-Host "5. Verificando Jenkins..." -ForegroundColor Yellow
try {
    $jenkinsStatus = docker-compose ps jenkins 2>&1
    if ($jenkinsStatus -match "Up") {
        Write-Host "   ✓ Jenkins está corriendo" -ForegroundColor Green
        Write-Host "   → URL: http://localhost:8080" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠ Jenkins no está corriendo" -ForegroundColor Yellow
        Write-Host "     Ejecuta: docker-compose up -d jenkins" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠ No se puede determinar estado de Jenkins" -ForegroundColor Yellow
}
Write-Host ""

# Verificar estructura de tests
Write-Host "6. Verificando estructura de tests..." -ForegroundColor Yellow
if (Test-Path "tests") {
    $testFiles = Get-ChildItem -Path "tests" -Filter "*.test.js"
    Write-Host "   ✓ Directorio de tests existe" -ForegroundColor Green
    Write-Host "   → $($testFiles.Count) archivos de test encontrados" -ForegroundColor Cyan
} else {
    Write-Host "   ✗ Directorio de tests no existe" -ForegroundColor Red
}
Write-Host ""

# Verificar Jenkinsfile
Write-Host "7. Analizando Jenkinsfile..." -ForegroundColor Yellow
if (Test-Path "Jenkinsfile") {
    $jenkinsfileContent = Get-Content "Jenkinsfile" -Raw
    
    $stages = @(
        "Checkout",
        "Unit Tests",
        "Security Scan",
        "Setup Terraform",
        "Terraform Init",
        "Terraform Validate",
        "Terraform Plan",
        "Terraform Apply",
        "Deploy to Dev"
    )
    
    foreach ($stage in $stages) {
        if ($jenkinsfileContent -match "stage\('$stage'\)") {
            Write-Host "   ✓ Stage: $stage" -ForegroundColor Green
        } else {
            Write-Host "   ✗ Stage falta: $stage" -ForegroundColor Red
        }
    }
    
    # Verificar agentes
    Write-Host ""
    Write-Host "   Verificando agentes configurados..." -ForegroundColor Cyan
    if ($jenkinsfileContent -match "agent none") {
        Write-Host "   ✓ Pipeline sin agente global (correcto)" -ForegroundColor Green
    }
    if ($jenkinsfileContent -match "docker.*node:18") {
        Write-Host "   ✓ Agente Node.js configurado" -ForegroundColor Green
    }
    if ($jenkinsfileContent -match "docker.*checkov") {
        Write-Host "   ✓ Agente Checkov configurado" -ForegroundColor Green
    }
} else {
    Write-Host "   ✗ Jenkinsfile no encontrado" -ForegroundColor Red
}
Write-Host ""

# Resumen
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "RESUMEN" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

if ($allFilesPresent) {
    Write-Host "✓ Todos los archivos necesarios están presentes" -ForegroundColor Green
} else {
    Write-Host "✗ Algunos archivos están faltando" -ForegroundColor Red
}

Write-Host ""
Write-Host "PRÓXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "1. Asegúrate de que Docker Desktop esté corriendo" -ForegroundColor White
Write-Host "2. Inicia Jenkins: docker-compose up -d jenkins" -ForegroundColor White
Write-Host "3. Espera ~2 minutos a que Jenkins inicie completamente" -ForegroundColor White
Write-Host "4. Accede a: http://localhost:8080" -ForegroundColor White
Write-Host "5. Usuario: admin | Contraseña: (ver .env o 'ElMundoFitness2024!')" -ForegroundColor White
Write-Host "6. Crea un nuevo Pipeline job apuntando a tu repositorio" -ForegroundColor White
Write-Host "7. Ejecuta el pipeline con ACTION=plan para probar" -ForegroundColor White
Write-Host ""
Write-Host "📚 Lee PIPELINE_COMPLETO.md para más detalles" -ForegroundColor Cyan
Write-Host ""
