// ============================================
// JENKINSFILE SIMPLE - PARA DEMOSTRACI√ìN
// Proyecto: El Mundo Fitness - Docker Agent Demo
// ============================================

pipeline {
    agent {
        label 'docker-agent'
    }
    
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '================================================'
                echo 'Ì≥¶ C√≥digo descargado'
                echo '================================================'
                checkout scm
                sh 'ls -la && pwd'
            }
        }
        
        stage('Environment Info') {
            steps {
                echo 'Ì¥ç Informaci√≥n del entorno'
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
            echo '‚úÖ Pipeline completado'
            cleanWs()
        }
    }
}
