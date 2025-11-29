// ============================================
// JENKINSFILE - EL MUNDO FITNESS
// Terraform Pipeline con Docker Agent
// ============================================

pipeline {
    agent {
        label 'docker-agent'
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Accion de Terraform a ejecutar'
        )
        string(
            name: 'ENVIRONMENT',
            defaultValue: 'dev',
            description: 'Entorno (dev/prod)'
        )
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '================================================'
                echo 'Descargando codigo del repositorio'
                echo '================================================'
                checkout scm
                sh '''
                    echo "Branch: ${GIT_BRANCH}"
                    echo "Commit: ${GIT_COMMIT}"
                    ls -la
                '''
            }
        }
        
        stage('Setup Terraform') {
            steps {
                echo '================================================'
                echo 'Configurando Terraform'
                echo '================================================'
                sh '''
                    # Intentar instalar curl si no existe
                    if ! command -v curl >/dev/null 2>&1; then
                        echo "Instalando curl..."
                        apt-get update -qq && apt-get install -y -qq curl unzip > /dev/null 2>&1 || true
                    fi
                    
                    # Descargar Terraform
                    if [ ! -f terraform ]; then
                        echo "Descargando Terraform 1.6.6..."
                        curl -sL https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip -o terraform.zip
                        unzip -q terraform.zip
                        chmod +x terraform
                        rm terraform.zip
                    fi
                    
                    ./terraform version
                '''
            }
        }
        
        stage('Environment Info') {
            steps {
                echo '================================================'
                echo 'Informacion del entorno'
                echo '================================================'
                sh '''
                    uname -a
                    whoami
                    echo "Action: ${ACTION}"
                    echo "Environment: ${ENVIRONMENT}"
                    ./terraform version
                '''
            }
        }
        
        stage('Terraform Init') {
            steps {
                echo '================================================'
                echo 'Inicializando Terraform'
                echo '================================================'
                sh '''
                    ./terraform init -backend=false
                '''
            }
        }
        
        stage('Terraform Validate') {
            steps {
                echo '================================================'
                echo 'Validando configuracion de Terraform'
                echo '================================================'
                sh '''
                    ./terraform validate
                    echo "Configuracion valida"
                '''
            }
        }
        
        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            steps {
                echo '================================================'
                echo 'Generando plan de Terraform'
                echo '================================================'
                sh '''
                    ./terraform plan \
                        -var="environment=${ENVIRONMENT}" \
                        -out=tfplan \
                        -input=false
                    
                    echo ""
                    echo "=== Plan Summary ==="
                    ./terraform show -no-color tfplan | head -50
                '''
            }
        }
        
        stage('Terraform Plan Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                echo '================================================'
                echo 'Generando plan de destruccion'
                echo '================================================'
                sh '''
                    ./terraform plan -destroy \
                        -var="environment=${ENVIRONMENT}" \
                        -out=tfplan \
                        -input=false
                    
                    echo ""
                    echo "=== Destroy Plan Summary ==="
                    ./terraform show -no-color tfplan | head -50
                '''
            }
        }
        
        stage('Approval for Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo 'Esperando aprobacion para aplicar cambios...'
                input message: 'Aplicar los cambios en AWS?', ok: 'Si, aplicar'
            }
        }
        
        stage('Approval for Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                echo 'Esperando aprobacion para destruir infraestructura...'
                input message: 'DESTRUIR la infraestructura en AWS?', ok: 'Si, destruir'
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo '================================================'
                echo 'Aplicando cambios en AWS'
                echo '================================================'
                sh '''
                    ./terraform apply -auto-approve tfplan
                    echo "Infraestructura desplegada exitosamente"
                '''
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                echo '================================================'
                echo 'Destruyendo infraestructura'
                echo '================================================'
                sh '''
                    ./terraform apply -auto-approve tfplan
                    echo "Infraestructura destruida"
                '''
            }
        }
        
        stage('Show Outputs') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo '================================================'
                echo 'Outputs de Terraform'
                echo '================================================'
                sh '''
                    ./terraform output -json > outputs.json || true
                    cat outputs.json || echo "No hay outputs disponibles"
                '''
            }
        }
    }
    
    post {
        always {
            echo '================================================'
            echo 'Limpieza'
            echo '================================================'
            sh '''
                ls -lh tfplan 2>/dev/null || echo "No hay plan file"
                ls -lh terraform 2>/dev/null || echo "No hay terraform binary"
            '''
        }
        success {
            echo '================================================'
            echo 'Pipeline ejecutado exitosamente'
            echo '================================================'
            echo "Accion: ${params.ACTION}"
            echo "Entorno: ${params.ENVIRONMENT}"
        }
        failure {
            echo '================================================'
            echo 'Pipeline fallo'
            echo '================================================'
            echo 'Revisa los logs para identificar el problema'
        }
    }
}
