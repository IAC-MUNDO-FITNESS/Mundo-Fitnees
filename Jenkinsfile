// ============================================
// JENKINSFILE - EL MUNDO FITNESS
// Terraform Pipeline con Docker Agent
// ============================================

pipeline {
    agent none
    
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
            agent {
                label 'docker-agent'
            }
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
                stash includes: '**/*', name: 'workspace'
            }
        }
        
        stage('Environment Info') {
            agent {
                docker {
                    image 'hashicorp/terraform:1.6'
                    label 'docker-agent'
                    reuseNode false
                }
            }
            steps {
                echo '================================================'
                echo 'Informacion del entorno'
                echo '================================================'
                sh '''
                    uname -a
                    whoami
                    echo "Action: ${ACTION}"
                    echo "Environment: ${ENVIRONMENT}"
                    terraform version
                '''
            }
        }
        
        stage('Terraform Init') {
            agent {
                docker {
                    image 'hashicorp/terraform:1.6'
                    label 'docker-agent'
                    reuseNode false
                }
            }
            steps {
                echo '================================================'
                echo 'Inicializando Terraform'
                echo '================================================'
                unstash 'workspace'
                sh '''
                    terraform version
                    terraform init -backend=false
                '''
            }
        }
        
        stage('Terraform Validate') {
            agent {
                docker {
                    image 'hashicorp/terraform:1.6'
                    label 'docker-agent'
                    reuseNode false
                }
            }
            steps {
                echo '================================================'
                echo 'Validando configuracion de Terraform'
                echo '================================================'
                unstash 'workspace'
                sh '''
                    terraform init -backend=false
                    terraform validate
                    echo "Configuracion valida"
                '''
            }
        }
        
        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            agent {
                docker {
                    image 'hashicorp/terraform:1.6'
                    label 'docker-agent'
                    reuseNode false
                }
            }
            steps {
                echo '================================================'
                echo 'Generando plan de Terraform'
                echo '================================================'
                unstash 'workspace'
                sh '''
                    terraform init -backend=false
                    terraform plan \
                        -var="environment=${ENVIRONMENT}" \
                        -out=tfplan \
                        -input=false
                    
                    echo ""
                    echo "=== Plan Summary ==="
                    terraform show -no-color tfplan | head -50
                '''
                stash includes: 'tfplan', name: 'tfplan'
            }
        }
        
        stage('Terraform Plan Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            agent {
                docker {
                    image 'hashicorp/terraform:1.6'
                    label 'docker-agent'
                    reuseNode false
                }
            }
            steps {
                echo '================================================'
                echo 'Generando plan de destruccion'
                echo '================================================'
                unstash 'workspace'
                sh '''
                    terraform init -backend=false
                    terraform plan -destroy \
                        -var="environment=${ENVIRONMENT}" \
                        -out=tfplan \
                        -input=false
                    
                    echo ""
                    echo "=== Destroy Plan Summary ==="
                    terraform show -no-color tfplan | head -50
                '''
                stash includes: 'tfplan', name: 'tfplan'
            }
        }
        
        stage('Approval for Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            agent {
                label 'docker-agent'
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
            agent {
                label 'docker-agent'
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
            agent {
                docker {
                    image 'hashicorp/terraform:1.6'
                    label 'docker-agent'
                    reuseNode false
                }
            }
            steps {
                echo '================================================'
                echo 'Aplicando cambios en AWS'
                echo '================================================'
                unstash 'workspace'
                unstash 'tfplan'
                sh '''
                    terraform init -backend=false
                    terraform apply -auto-approve tfplan
                    echo "Infraestructura desplegada exitosamente"
                '''
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            agent {
                docker {
                    image 'hashicorp/terraform:1.6'
                    label 'docker-agent'
                    reuseNode false
                }
            }
            steps {
                echo '================================================'
                echo 'Destruyendo infraestructura'
                echo '================================================'
                unstash 'workspace'
                unstash 'tfplan'
                sh '''
                    terraform init -backend=false
                    terraform apply -auto-approve tfplan
                    echo "Infraestructura destruida"
                '''
            }
        }
        
        stage('Show Outputs') {
            when {
                expression { params.ACTION == 'apply' }
            }
            agent {
                docker {
                    image 'hashicorp/terraform:1.6'
                    label 'docker-agent'
                    reuseNode false
                }
            }
            steps {
                echo '================================================'
                echo 'Outputs de Terraform'
                echo '================================================'
                unstash 'workspace'
                sh '''
                    terraform init -backend=false
                    terraform output -json > outputs.json || true
                    cat outputs.json || echo "No hay outputs disponibles"
                '''
            }
        }
    }
    
    post {
        success {
            node('docker-agent') {
                echo '================================================'
                echo 'Pipeline ejecutado exitosamente'
                echo '================================================'
                echo "Accion: ${params.ACTION}"
                echo "Entorno: ${params.ENVIRONMENT}"
            }
        }
        failure {
            node('docker-agent') {
                echo '================================================'
                echo 'Pipeline fallo'
                echo '================================================'
                echo 'Revisa los logs para identificar el problema'
            }
        }
    }
}
