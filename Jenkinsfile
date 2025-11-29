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
            choices: ['plan', 'apply', 'destroy', 'metrics'],
            description: 'Accion de Terraform a ejecutar'
        )
        string(
            name: 'ENVIRONMENT',
            defaultValue: 'dev',
            description: 'Entorno (dev/prod)'
        )
        string(
            name: 'AWS_CREDENTIALS_ID',
            defaultValue: 'aws-elmundo-fitness',
            description: 'ID de las credenciales AWS configuradas en Jenkins'
        )
        string(
            name: 'AWS_REGION',
            defaultValue: 'us-east-1',
            description: 'Region de AWS que usara Terraform'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Omite la aprobacion manual para apply/destroy'
        )
            booleanParam(
                name: 'RESTORE_STATE_FROM_BACKUP',
                defaultValue: false,
                description: 'Copia terraform.tfstate.backup sobre terraform.tfstate antes de ejecutar Terraform'
            )
        booleanParam(
            name: 'RESTORE_STATE_FROM_BACKUP',
            defaultValue: false,
            description: 'Copia terraform.tfstate.backup sobre terraform.tfstate antes de ejecutar Terraform'
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
                        if command -v unzip >/dev/null 2>&1; then
                            unzip -q terraform.zip
                        else
                            echo "unzip no esta disponible, usando jar para extraer"
                            jar xf terraform.zip
                        fi
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
                    echo "Restore state from backup: ${RESTORE_STATE_FROM_BACKUP}"
                    ./terraform version
                '''
            }
        }

            stage('Restore State') {
                when {
                    expression { params.RESTORE_STATE_FROM_BACKUP }
                }
                steps {
        stage('Restore State') {
            when {
                expression { params.RESTORE_STATE_FROM_BACKUP }
            }
            steps {
                    script {
                        echo '================================================'
                        echo 'Restaurando estado de Terraform desde backup'
                        echo '================================================'

                        if (!fileExists('terraform.tfstate.backup')) {
                            echo 'No se encontro terraform.tfstate.backup en el workspace actual. Intentando recuperar del ultimo build exitoso...'
                            try {
                                copyArtifacts(
                                    projectName: env.JOB_NAME,
                                    selector: lastSuccessful(),
                                    filter: 'terraform.tfstate.backup',
                                    optional: true
                                )
                            } catch (err) {
                                echo "No se pudo copiar el backup desde otro build: ${err.message}"
                            }
                        }

                        if (!fileExists('terraform.tfstate.backup')) {
                            error 'No se encontro terraform.tfstate.backup; sube el archivo como artefacto o desactiva RESTORE_STATE_FROM_BACKUP.'
                        }

                        sh '''
                            set -e
                            cp terraform.tfstate.backup terraform.tfstate
                            echo "Estado restaurado."
                            ls -l terraform.tfstate*
                        '''
                    }
            }
        }
        
        stage('Terraform Init') {
            steps {
                echo '================================================'
                echo 'Inicializando Terraform'
                echo '================================================'
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        withEnv([
                            "AWS_DEFAULT_REGION=${params.AWS_REGION}",
                            "AWS_REGION=${params.AWS_REGION}"
                        ]) {
                            sh '''
                                ./terraform init -backend=false
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                echo '================================================'
                echo 'Validando configuracion de Terraform'
                echo '================================================'
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        withEnv([
                            "AWS_DEFAULT_REGION=${params.AWS_REGION}",
                            "AWS_REGION=${params.AWS_REGION}"
                        ]) {
                            sh '''
                                ./terraform validate
                                echo "Configuracion valida"
                            '''
                        }
                    }
                }
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
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        withEnv([
                            "AWS_DEFAULT_REGION=${params.AWS_REGION}",
                            "AWS_REGION=${params.AWS_REGION}"
                        ]) {
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
                }
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
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        withEnv([
                            "AWS_DEFAULT_REGION=${params.AWS_REGION}",
                            "AWS_REGION=${params.AWS_REGION}"
                        ]) {
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
                }
            }
        }
        
        stage('Generate Sample Metrics') {
            when {
                expression { params.ACTION == 'metrics' }
            }
            steps {
                echo '================================================'
                echo 'Generando metricas de prueba en CloudWatch'
                echo '================================================'
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        withEnv([
                            "AWS_DEFAULT_REGION=${params.AWS_REGION}",
                            "AWS_REGION=${params.AWS_REGION}"
                        ]) {
                            sh '''
                                set -e

                                ensure_awscli() {
                                    if command -v aws >/dev/null 2>&1; then
                                        return
                                    fi

                                    if ! command -v pip3 >/dev/null 2>&1; then
                                        if command -v apt-get >/dev/null 2>&1; then
                                            apt-get update -qq >/dev/null 2>&1
                                            apt-get install -y -qq python3-pip >/dev/null 2>&1 || true
                                        fi
                                    fi

                                    if command -v pip3 >/dev/null 2>&1; then
                                        pip3 install --user awscli >/dev/null 2>&1 || pip3 install awscli >/dev/null 2>&1 || true
                                    fi

                                    export PATH="$HOME/.local/bin:$PATH"

                                    if ! command -v aws >/dev/null 2>&1; then
                                        echo "No se pudo instalar awscli automaticamente" >&2
                                        exit 1
                                    fi
                                }

                                ensure_awscli
                                export PATH="$HOME/.local/bin:$PATH"

                                echo "Invocando lambdas para generar eventos..."
                                for fn in subscription-control access-control notification-service; do
                                    NAME="elmundo-fitness-${ENVIRONMENT}-${fn}"
                                    aws lambda invoke \
                                        --function-name "$NAME" \
                                        --payload '{}' \
                                        --cli-binary-format raw-in-base64-out \
                                        "/tmp/${fn}.json" >/dev/null 2>&1 || true
                                done

                                echo "Publicando metricas sinteticas en CloudWatch"
                                aws cloudwatch put-metric-data \
                                    --namespace "ElMundoFitness/Synthetic" \
                                    --metric-data "MetricName=CheckoutLatency,Unit=Milliseconds,Value=125" \
                                    >/dev/null 2>&1 || true
                                aws cloudwatch put-metric-data \
                                    --namespace "ElMundoFitness/Synthetic" \
                                    --metric-data "MetricName=CheckoutSuccess,Unit=Count,Value=1" \
                                    >/dev/null 2>&1 || true

                                echo "Metricas generadas. Espera 1-2 minutos y refresca Grafana."
                            '''
                        }
                    }
                }
            }
        }

        stage('Approval for Apply') {
            when {
                expression { params.ACTION == 'apply' && !params.AUTO_APPROVE }
            }
            steps {
                echo 'Esperando aprobacion para aplicar cambios...'
                input message: 'Aplicar los cambios en AWS?', ok: 'Si, aplicar'
            }
        }
        
        stage('Approval for Destroy') {
            when {
                expression { params.ACTION == 'destroy' && !params.AUTO_APPROVE }
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
                script {
                    if (params.AUTO_APPROVE) {
                        echo 'AUTO_APPROVE habilitado: ejecutando apply sin aprobacion manual'
                    }
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        withEnv([
                            "AWS_DEFAULT_REGION=${params.AWS_REGION}",
                            "AWS_REGION=${params.AWS_REGION}"
                        ]) {
                            sh '''
                                ./terraform apply -auto-approve tfplan
                                echo "Infraestructura desplegada exitosamente"
                            '''
                        }
                    }
                }
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
                script {
                    if (params.AUTO_APPROVE) {
                        echo 'AUTO_APPROVE habilitado: ejecutando destroy sin aprobacion manual'
                    }
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        withEnv([
                            "AWS_DEFAULT_REGION=${params.AWS_REGION}",
                            "AWS_REGION=${params.AWS_REGION}"
                        ]) {
                            sh '''
                                ./terraform apply -auto-approve tfplan
                                echo "Infraestructura destruida"
                            '''
                        }
                    }
                }
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
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        withEnv([
                            "AWS_DEFAULT_REGION=${params.AWS_REGION}",
                            "AWS_REGION=${params.AWS_REGION}"
                        ]) {
                            sh '''
                                ./terraform output -json > outputs.json || true
                                cat outputs.json || echo "No hay outputs disponibles"
                            '''
                        }
                    }
                }
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
            script {
                def artifacts = []
                if (fileExists('terraform.tfstate')) {
                    artifacts << 'terraform.tfstate'
                }
                if (fileExists('terraform.tfstate.backup')) {
                    artifacts << 'terraform.tfstate.backup'
                }

                if (!artifacts.isEmpty()) {
                    echo 'Archivando estado de Terraform para uso futuro'
                    archiveArtifacts artifacts: artifacts.join(', '), onlyIfSuccessful: false
                } else {
                    echo 'No hay archivos de estado para archivar'
                }
            }
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
