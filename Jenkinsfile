// ============================================
// JENKINSFILE - DECLARATIVE PIPELINE
// Proyecto: El Mundo Fitness - IaC con Terraform
// ============================================

pipeline {
    agent any  // Usa cualquier agente disponible (temporalmente)
    
    // Variables de entorno
    environment {
        // Región de AWS
        AWS_REGION = 'us-east-1'
        
        // Directorio de trabajo de Terraform
        TF_IN_AUTOMATION = 'true'
        
        // Versión de Terraform (ajustar según tu versión instalada)
        TF_VERSION = '1.6.0'
    }
    
    // Parámetros del pipeline (opcional)
    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Selecciona la acción de Terraform a ejecutar'
        )
        string(
            name: 'ENVIRONMENT',
            defaultValue: 'dev',
            description: 'Ambiente a desplegar (dev, staging, prod)'
        )
    }
    
    stages {
        // ============================================
        // STAGE 1: Checkout del código
        // ============================================
        stage('Checkout') {
            steps {
                echo '================================================'
                echo '🔄 Descargando código del repositorio...'
                echo '================================================'
                
                // Descargar código desde Git
                checkout scm
                
                // Mostrar información del commit
                powershell '''
                    Write-Host ("Branch: " + $env:GIT_BRANCH)
                    Write-Host ("Commit: " + $env:GIT_COMMIT)
                    git log -1 --pretty=format:"%h - %an, %ar : %s" | Write-Host
                '''
            }
        }
        
        // ============================================
        // STAGE 2: Validar credenciales de AWS
        // ============================================
        stage('Validate AWS Credentials') {
            steps {
                echo '================================================'
                echo '🔑 Validando credenciales de AWS...'
                echo '================================================'
                
                // Inyectar credenciales de AWS desde Jenkins Credentials
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    powershell '''
                        aws sts get-caller-identity | Out-String | Write-Host
                        Write-Host ("Región de AWS: " + $env:AWS_REGION)
                    '''
                }
            }
        }
        
        // ============================================
        // STAGE 3: Terraform Init
        // ============================================
        stage('Terraform Init') {
            steps {
                echo '================================================'
                echo '🔧 Inicializando Terraform...'
                echo '================================================'
                
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    powershell '''
                        terraform init -input=false
                        terraform validate
                        # Formatear (no falla si hay diferencias)
                        terraform fmt -recursive | Out-Null
                    '''
                }
            }
        }
        
        // ============================================
        // STAGE 4: Terraform Plan
        // ============================================
        stage('Terraform Plan') {
            steps {
                echo '================================================'
                echo '📋 Generando plan de ejecución de Terraform...'
                echo '================================================'
                
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    powershell '''
                        terraform plan -var="environment=$env:ENVIRONMENT" -out=tfplan -input=false
                        terraform show -no-color tfplan > tfplan.txt
                        Write-Host "`n✅ Plan generado exitosamente"
                        Write-Host "📄 Revisa el archivo tfplan.txt para ver los detalles"
                    '''
                }
                
                // Archivar el plan para revisión
                archiveArtifacts artifacts: 'tfplan.txt', fingerprint: true
            }
        }
        
        // ============================================
        // STAGE 5: Aprobación Manual (Solo para Apply)
        // ============================================
        stage('Approval') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                echo '================================================'
                echo '⏸️  Esperando aprobación manual...'
                echo '================================================'
                
                script {
                    // Esperar aprobación manual antes de aplicar cambios
                    def userInput = input(
                        id: 'userInput',
                        message: '¿Deseas continuar con el despliegue?',
                        parameters: [
                            choice(
                                name: 'PROCEED',
                                choices: ['No', 'Yes'],
                                description: 'Confirma si deseas aplicar los cambios'
                            )
                        ]
                    )
                    
                    if (userInput == 'No') {
                        error('❌ Despliegue cancelado por el usuario')
                    }
                    
                    echo '✅ Aprobación concedida. Continuando...'
                }
            }
        }
        
        // ============================================
        // STAGE 6: Terraform Apply
        // ============================================
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo '================================================'
                echo '🚀 Aplicando cambios de infraestructura...'
                echo '================================================'
                
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    powershell '''
                        terraform apply -input=false -auto-approve tfplan
                        Write-Host "`n✅ Infraestructura desplegada exitosamente`n"
                        Write-Host "📊 Outputs de la infraestructura:"
                        terraform output -json > outputs.json
                        terraform output | Out-String | Write-Host
                    '''
                }
                
                // Archivar los outputs
                archiveArtifacts artifacts: 'outputs.json', fingerprint: true
            }
        }
        
        // ============================================
        // STAGE 7: Start Grafana Monitoring (Después de Apply)
        // ============================================
        stage('Start Grafana') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo '================================================'
                echo '📊 Iniciando Grafana para monitoreo...'
                echo '================================================'
                
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    powershell '''
                        # Verificar si Docker está corriendo
                        try {
                            docker --version
                            docker-compose --version
                            Write-Host "✅ Docker está instalado y corriendo" -ForegroundColor Green
                        } catch {
                            Write-Host "⚠️  Docker no está disponible. Saltando Grafana..." -ForegroundColor Yellow
                            exit 0
                        }
                        
                        # Crear archivo .env con credenciales
                        @"
AWS_ACCESS_KEY_ID=${env:AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${env:AWS_SECRET_ACCESS_KEY}
AWS_REGION=${env:AWS_REGION}
"@ | Out-File -FilePath .env -Encoding utf8 -Force
                        
                        Write-Host "✅ Archivo .env creado" -ForegroundColor Green
                        
                        # Iniciar container de Grafana
                        docker-compose up -d grafana
                        
                        # Esperar a que Grafana esté listo
                        Write-Host "⏳ Esperando a que Grafana inicie..." -ForegroundColor Yellow
                        Start-Sleep -Seconds 15
                        
                        # Verificar estado
                        $status = docker-compose ps grafana
                        Write-Host $status
                        
                        if ($status -match "Up") {
                            Write-Host "" 
                            Write-Host "✅ Grafana iniciado exitosamente" -ForegroundColor Green
                            Write-Host "📊 Accede a: http://localhost:3000" -ForegroundColor Cyan
                            Write-Host "🔑 Usuario: admin / Contraseña: ElMundoFitness2024!" -ForegroundColor Cyan
                            Write-Host ""
                        } else {
                            Write-Host "⚠️  Grafana no se inició correctamente" -ForegroundColor Yellow
                            docker-compose logs grafana
                        }
                        
                        # Limpiar archivo .env por seguridad
                        Remove-Item -Path .env -Force -ErrorAction SilentlyContinue
                    '''
                }
            }
        }
        
        // ============================================
        // STAGE 8: Terraform Destroy (Opcional)
        // ============================================
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                echo '================================================'
                echo '💣 DESTRUYENDO infraestructura...'
                echo '================================================'
                
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    powershell '''
                        terraform destroy -var="environment=$env:ENVIRONMENT" -auto-approve
                        Write-Host "`n✅ Infraestructura destruida exitosamente"
                    '''
                }
                
                // Detener Grafana si está corriendo
                powershell '''
                    Write-Host "🛑 Deteniendo Grafana..." -ForegroundColor Yellow
                    docker-compose down
                '''
            }
        }
    }
    
    // ============================================
    // POST: Acciones después del pipeline
    // ============================================
    post {
        success {
            echo '================================================'
            echo '✅ Pipeline ejecutado exitosamente'
            echo '================================================'
            
            script {
                if (params.ACTION == 'apply') {
                    echo '🎉 Infraestructura desplegada correctamente'
                    echo '📊 Revisa los outputs en el archivo outputs.json'
                    echo ''
                    echo '📊 GRAFANA MONITORING:'
                    echo '   URL: http://localhost:3000'
                    echo '   User: admin'
                    echo '   Pass: ElMundoFitness2024!'
                    echo ''
                    echo '⚠️  IMPORTANTE:'
                    echo '   1. Verifica el email en SES antes de enviar recibos'
                    echo '   2. Los logs se guardan por ${CLOUDWATCH_LOG_RETENTION:-30} días'
                    echo '   3. Ver GRAFANA_README.md para más detalles'
                }
            }
        }
        
        failure {
            echo '================================================'
            echo '❌ Pipeline falló'
            echo '================================================'
            echo 'Revisa los logs para identificar el problema'
        }
        
        always {
            echo '================================================'
            echo '🧹 Limpieza de archivos temporales...'
            echo '================================================'
            
            // Limpiar archivos temporales (opcional)
            powershell '''
                if (Test-Path tfplan) { Remove-Item tfplan -Force }
                if (Test-Path tfplan.txt) { Remove-Item tfplan.txt -Force }
            '''
        }
    }
}
