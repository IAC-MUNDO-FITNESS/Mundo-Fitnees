// ============================================
// JENKINSFILE SIMPLE - PARA DEMOSTRACIÓN
// Proyecto: El Mundo Fitness - Docker Agent Demo
// ============================================

pipeline {
    agent {
        label 'docker-agent'
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '================================================'
                echo '��� Código descargado'
                echo '================================================'
                checkout scm
                sh 'ls -la && pwd'
            }
        }
        
        stage('Environment Info') {
            steps {
                echo '��� Información del entorno'
                sh '''
                    uname -a
                    whoami
                    echo "Node: ${NODE_NAME}"
                '''
            }
        }
        
        stage('Terraform Check') {
            steps {
                script {
                    docker.image('hashicorp/terraform:latest').inside {
                        sh 'terraform version'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo '✅ Pipeline completado'
            cleanWs()
        }
    }
}
