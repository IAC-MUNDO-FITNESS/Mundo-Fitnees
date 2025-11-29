# ============================================
# Script de Despliegue - El Mundo Fitness
# PowerShell Script para Windows
# ============================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('init', 'plan', 'apply', 'destroy', 'output', 'validate')]
    [string]$Action = 'plan',
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = 'dev',
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove = $false
)

# Colores para output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

# Banner
function Show-Banner {
    Write-Host "============================================" -ForegroundColor $InfoColor
    Write-Host "  EL MUNDO FITNESS - Despliegue IaC" -ForegroundColor $InfoColor
    Write-Host "  Terraform + AWS" -ForegroundColor $InfoColor
    Write-Host "============================================" -ForegroundColor $InfoColor
    Write-Host ""
}

# Validar requisitos
function Test-Requirements {
    Write-Host "Validando requisitos previos..." -ForegroundColor $InfoColor
    
    # Verificar Terraform
    try {
        $tfVersion = terraform --version
        Write-Host "✓ Terraform instalado: $($tfVersion[0])" -ForegroundColor $SuccessColor
    } catch {
        Write-Host "✗ Terraform no está instalado" -ForegroundColor $ErrorColor
        Write-Host "Instálalo desde: https://www.terraform.io/downloads" -ForegroundColor $WarningColor
        exit 1
    }
    
    # Verificar AWS CLI
    try {
        $awsVersion = aws --version
        Write-Host "✓ AWS CLI instalado: $awsVersion" -ForegroundColor $SuccessColor
    } catch {
        Write-Host "✗ AWS CLI no está instalado" -ForegroundColor $ErrorColor
        Write-Host "Instálalo desde: https://aws.amazon.com/cli/" -ForegroundColor $WarningColor
        exit 1
    }
    
    # Verificar credenciales de AWS
    try {
        $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
        Write-Host "✓ Credenciales de AWS configuradas" -ForegroundColor $SuccessColor
        Write-Host "  Account: $($identity.Account)" -ForegroundColor $InfoColor
        Write-Host "  User: $($identity.Arn)" -ForegroundColor $InfoColor
    } catch {
        Write-Host "✗ Credenciales de AWS no configuradas" -ForegroundColor $ErrorColor
        Write-Host "Ejecuta: aws configure" -ForegroundColor $WarningColor
        exit 1
    }
    
    Write-Host ""
}

# Terraform Init
function Invoke-TerraformInit {
    Write-Host "============================================" -ForegroundColor $InfoColor
    Write-Host "Inicializando Terraform..." -ForegroundColor $InfoColor
    Write-Host "============================================" -ForegroundColor $InfoColor
    
    terraform init
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Terraform inicializado correctamente" -ForegroundColor $SuccessColor
        
        # Validar configuración
        Write-Host "`nValidando configuración..." -ForegroundColor $InfoColor
        terraform validate
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Configuración válida" -ForegroundColor $SuccessColor
        } else {
            Write-Host "✗ Error en la validación" -ForegroundColor $ErrorColor
            exit 1
        }
    } else {
        Write-Host "✗ Error al inicializar Terraform" -ForegroundColor $ErrorColor
        exit 1
    }
    
    Write-Host ""
}

# Terraform Plan
function Invoke-TerraformPlan {
    Write-Host "============================================" -ForegroundColor $InfoColor
    Write-Host "Generando plan de ejecución..." -ForegroundColor $InfoColor
    Write-Host "============================================" -ForegroundColor $InfoColor
    
    terraform plan -var="environment=$Environment" -out=tfplan
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ Plan generado correctamente" -ForegroundColor $SuccessColor
        Write-Host "Revisa los cambios antes de aplicar" -ForegroundColor $WarningColor
    } else {
        Write-Host "`n✗ Error al generar el plan" -ForegroundColor $ErrorColor
        exit 1
    }
    
    Write-Host ""
}

# Terraform Apply
function Invoke-TerraformApply {
    Write-Host "============================================" -ForegroundColor $InfoColor
    Write-Host "Aplicando cambios de infraestructura..." -ForegroundColor $InfoColor
    Write-Host "============================================" -ForegroundColor $InfoColor
    
    # Confirmar antes de aplicar
    if (-not $AutoApprove) {
        Write-Host "`n⚠️  ADVERTENCIA: Esto desplegará recursos en AWS" -ForegroundColor $WarningColor
        Write-Host "Esto generará costos en tu cuenta de AWS" -ForegroundColor $WarningColor
        $confirmation = Read-Host "`n¿Deseas continuar? (yes/no)"
        
        if ($confirmation -ne 'yes') {
            Write-Host "Operación cancelada" -ForegroundColor $WarningColor
            exit 0
        }
    }
    
    if ($AutoApprove) {
        terraform apply -var="environment=$Environment" -auto-approve
    } else {
        terraform apply -var="environment=$Environment"
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ Infraestructura desplegada exitosamente" -ForegroundColor $SuccessColor
        Write-Host "`nOutputs de la infraestructura:" -ForegroundColor $InfoColor
        terraform output
    } else {
        Write-Host "`n✗ Error al aplicar los cambios" -ForegroundColor $ErrorColor
        exit 1
    }
    
    Write-Host ""
}

# Terraform Destroy
function Invoke-TerraformDestroy {
    Write-Host "============================================" -ForegroundColor $InfoColor
    Write-Host "DESTRUYENDO infraestructura..." -ForegroundColor $ErrorColor
    Write-Host "============================================" -ForegroundColor $InfoColor
    
    # Confirmar antes de destruir
    if (-not $AutoApprove) {
        Write-Host "`n⚠️  PELIGRO: Esto eliminará TODA la infraestructura" -ForegroundColor $ErrorColor
        Write-Host "Se perderán todos los datos en DynamoDB y S3" -ForegroundColor $ErrorColor
        $confirmation = Read-Host "`n¿Estás SEGURO que deseas continuar? (yes/no)"
        
        if ($confirmation -ne 'yes') {
            Write-Host "Operación cancelada" -ForegroundColor $WarningColor
            exit 0
        }
        
        # Segunda confirmación
        $confirmation2 = Read-Host "`nEscribe 'DESTROY' para confirmar"
        
        if ($confirmation2 -ne 'DESTROY') {
            Write-Host "Operación cancelada" -ForegroundColor $WarningColor
            exit 0
        }
    }
    
    if ($AutoApprove) {
        terraform destroy -var="environment=$Environment" -auto-approve
    } else {
        terraform destroy -var="environment=$Environment"
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ Infraestructura eliminada exitosamente" -ForegroundColor $SuccessColor
    } else {
        Write-Host "`n✗ Error al destruir la infraestructura" -ForegroundColor $ErrorColor
        exit 1
    }
    
    Write-Host ""
}

# Terraform Output
function Show-TerraformOutput {
    Write-Host "============================================" -ForegroundColor $InfoColor
    Write-Host "Outputs de la infraestructura" -ForegroundColor $InfoColor
    Write-Host "============================================" -ForegroundColor $InfoColor
    
    terraform output
    
    Write-Host "`nPara ver un output específico:" -ForegroundColor $InfoColor
    Write-Host "terraform output <nombre_output>" -ForegroundColor $InfoColor
    Write-Host "`nPara ver en formato JSON:" -ForegroundColor $InfoColor
    Write-Host "terraform output -json" -ForegroundColor $InfoColor
    Write-Host ""
}

# Terraform Validate
function Invoke-TerraformValidate {
    Write-Host "============================================" -ForegroundColor $InfoColor
    Write-Host "Validando configuración de Terraform..." -ForegroundColor $InfoColor
    Write-Host "============================================" -ForegroundColor $InfoColor
    
    terraform validate
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ Configuración válida" -ForegroundColor $SuccessColor
        
        # Formatear archivos
        Write-Host "`nFormateando archivos..." -ForegroundColor $InfoColor
        terraform fmt -recursive
        Write-Host "✓ Archivos formateados" -ForegroundColor $SuccessColor
    } else {
        Write-Host "`n✗ Error en la configuración" -ForegroundColor $ErrorColor
        exit 1
    }
    
    Write-Host ""
}

# Main
Show-Banner
Test-Requirements

switch ($Action) {
    'init' {
        Invoke-TerraformInit
    }
    'plan' {
        Invoke-TerraformPlan
    }
    'apply' {
        Invoke-TerraformApply
    }
    'destroy' {
        Invoke-TerraformDestroy
    }
    'output' {
        Show-TerraformOutput
    }
    'validate' {
        Invoke-TerraformValidate
    }
}

Write-Host "============================================" -ForegroundColor $InfoColor
Write-Host "Proceso completado" -ForegroundColor $SuccessColor
Write-Host "============================================" -ForegroundColor $InfoColor
