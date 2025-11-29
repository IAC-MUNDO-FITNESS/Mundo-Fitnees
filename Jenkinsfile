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
        
        stage('Environment Info') {
            steps {
                echo '================================================'
                echo 'Informacion del entorno'
                echo '================================================'
                sh '''
                    uname -a
                    whoami
                    echo "Node: ${NODE_NAME}"
                    echo "Workspace: ${WORKSPACE}"
                    echo "Action: ${ACTION}"
                    echo "Environment: ${ENVIRONMENT}"
                '''
            }
        }
        
        stage('Install Terraform') {
            steps {
                echo '================================================'
                echo 'Instalando Terraform'
                echo '================================================'
                sh '''
                    # Verificar si terraform ya esta instalado
                    if command -v terraform >/dev/null 2>&1; then
                        echo "Terraform ya esta instalado:"
                        terraform version
                    else
                        echo "Instalando Terraform..."
                        wget -q https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
                        unzip -q terraform_1.6.6_linux_amd64.zip
                        chmod +x terraform
                        ./terraform version
                    fi
                '''
            }
        }
        
        stage('Terraform Init') {
            steps {
                echo '================================================'
                echo 'Inicializando Terraform'
                echo '================================================'
                sh '''
                    TERRAFORM_CMD=$(command -v terraform || echo "./terraform")
                    $TERRAFORM_CMD version
                    $TERRAFORM_CMD init -backend=false
                '''
            }
        }
        
        stage('Terraform Validate') {
            steps {
                echo '================================================'
                echo 'Validando configuracion de Terraform'
                echo '================================================'
                sh '''
                    TERRAFORM_CMD=$(command -v terraform || echo "./terraform")
                    $TERRAFORM_CMD validate
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
                    TERRAFORM_CMD=$(command -v terraform || echo "./terraform")
                    $TERRAFORM_CMD plan \
                        -var="environment=${ENVIRONMENT}" \
                        -out=tfplan \
                        -input=false
                    
                    echo ""
                    echo "=== Plan Summary ==="
                    $TERRAFORM_CMD show -no-color tfplan | head -50
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
                    TERRAFORM_CMD=$(command -v terraform || echo "./terraform")
                    $TERRAFORM_CMD plan -destroy \
                        -var="environment=${ENVIRONMENT}" \
                        -out=tfplan \
                        -input=false
                    
                    echo ""
                    echo "=== Destroy Plan Summary ==="
                    $TERRAFORM_CMD show -no-color tfplan | head -50
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
                    TERRAFORM_CMD=$(command -v terraform || echo "./terraform")
                    $TERRAFORM_CMD apply -auto-approve tfplan
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
                    TERRAFORM_CMD=$(command -v terraform || echo "./terraform")
                    $TERRAFORM_CMD apply -auto-approve tfplan
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
                    TERRAFORM_CMD=$(command -v terraform || echo "./terraform")
                    $TERRAFORM_CMD output -json > outputs.json || true
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
            sh 'ls -lh tfplan 2>/dev/null || echo "No hay plan file"'
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
