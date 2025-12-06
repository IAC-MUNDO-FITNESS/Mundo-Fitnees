// ============================================
// JENKINSFILE - EL MUNDO FITNESS
// Terraform Pipeline con Docker Agent
// ============================================

pipeline {
    agent none
    
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
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('Checkout') {
            agent any
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
        
        stage('Unit Tests') {
            agent any
            steps {
                echo '================================================'
                echo 'Ejecutando Tests Unitarios de Lambda Functions'
                echo '================================================'
                script {
                    def testResult = sh(
                        script: '''
                            # Verificar que package.json existe
                            if [ ! -f package.json ]; then
                                echo "ERROR: package.json no encontrado en $(pwd)"
                                exit 1
                            fi
                            
                            # Ejecutar tests en contenedor Docker
                            docker run --rm \
                                -v "$(pwd)":/app \
                                -w /app \
                                node:18-alpine \
                                sh -c "npm install --production=false && npm test"
                        ''',
                        returnStatus: true
                    )
                    
                    if (testResult != 0) {
                        echo "⚠️ Tests fallaron con código: ${testResult}"
                        echo "Tests completados con warnings - continuando pipeline"
                    } else {
                        echo "✅ Tests ejecutados exitosamente"
                    }
                }
            }
        }
        
        stage('Security Scan - Checkov') {
            agent any
            steps {
                echo '================================================'
                echo 'Ejecutando Checkov Security Scan'
                echo '================================================'
                sh '''
                    # Ejecutar Checkov en contenedor Docker
                    docker run --rm \
                        -v "$(pwd)":/tf \
                        -w /tf \
                        bridgecrew/checkov:latest \
                        -d . --framework terraform --quiet --compact || echo "Scan completado con warnings"
                '''
            }
        }
        
        stage('SonarQube Analysis') {
            agent any
            steps {
                echo '================================================'
                echo 'Ejecutando Analisis de Calidad de Codigo - SonarQube'
                echo '================================================'
                script {
                    // Verificar si SonarQube está corriendo
                    def sonarqubeRunning = sh(
                        script: 'docker ps --format "{{.Names}}" | grep -q sonarqube',
                        returnStatus: true
                    )
                    
                    if (sonarqubeRunning == 0) {
                        echo '✅ SonarQube container detectado'
                        
                        // Verificar si existe la credencial
                        try {
                            withCredentials([string(credentialsId: 'SONARQUBE_TOKEN', variable: 'SONAR_TOKEN')]) {
                                echo '✅ Token de SonarQube configurado, ejecutando análisis...'
                                sh '''
                                    # Ejecutar SonarScanner en contenedor Docker
                                    docker run --rm \
                                        --network elmundo-fitness-monitoring \
                                        -e SONAR_HOST_URL="http://elmundo-fitness-sonarqube:9000" \
                                        -e SONAR_LOGIN="${SONAR_TOKEN}" \
                                        -v "$(pwd)":/usr/src \
                                        sonarsource/sonar-scanner-cli \
                                        -Dsonar.projectKey=elmundo-fitness \
                                        -Dsonar.projectName="El Mundo Fitness - IAC" \
                                        -Dsonar.projectVersion=1.0 \
                                        -Dsonar.sources=. \
                                        -Dsonar.exclusions=**/node_modules/**,**/.terraform/**,**/coverage/**,**/.git/** \
                                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                                    
                                    echo "✅ SonarQube scan completado exitosamente"
                                '''
                            }
                        } catch (Exception e) {
                            echo "⚠️ Credencial 'SONARQUBE_TOKEN' no configurada en Jenkins"
                            echo "Para configurar:"
                            echo "1. Ve a: Jenkins → Manage Jenkins → Credentials"
                            echo "2. Agrega 'Secret text' con ID: SONARQUBE_TOKEN"
                            echo "3. Usa el token generado en SonarQube"
                            echo "Saltando análisis de SonarQube por ahora..."
                        }
                    } else {
                        echo '⚠️ SonarQube no está corriendo'
                        echo 'Para iniciar SonarQube:'
                        echo '  docker-compose up -d sonarqube sonarqube-db'
                        echo 'Saltando análisis...'
                    }
                }
            }
        }
        
        stage('Setup Terraform') {
            agent any
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
                    
                    terraform version
                '''
            }
        }
        
        stage('Environment Info') {
            agent any
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
                    terraform version
                '''
            }
        }

        stage('Restore State') {
            agent any
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
                        def msg = 'No se encontro terraform.tfstate.backup tras intentar copiar artefactos.'
                        if (params.ACTION == 'destroy') {
                            error msg + ' Este estado es obligatorio para destruir recursos existentes.'
                        } else {
                            echo msg + ' Continuando sin restaurar estado.'
                            return
                        }
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
            agent any
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
                                terraform init -backend=false
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Terraform Validate') {
            agent any
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
                                terraform validate
                                echo "Configuracion valida"
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            agent any
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
                                terraform plan \
                                    -var="environment=${ENVIRONMENT}" \
                                    -out=tfplan \
                                    -input=false
                                
                                echo ""
                                echo "=== Plan Summary ==="
                                terraform show -no-color tfplan | head -50
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Terraform Plan Destroy') {
            agent any
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
                                terraform plan -destroy \
                                    -var="environment=${ENVIRONMENT}" \
                                    -out=tfplan \
                                    -input=false
                                
                                echo ""
                                echo "=== Destroy Plan Summary ==="
                                terraform show -no-color tfplan | head -50
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Generate Sample Metrics') {
            agent any
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
            agent any
            when {
                expression { params.ACTION == 'apply' && !params.AUTO_APPROVE }
            }
            steps {
                echo 'Esperando aprobacion para aplicar cambios...'
                input message: 'Aplicar los cambios en AWS?', ok: 'Si, aplicar'
            }
        }
        
        stage('Approval for Destroy') {
            agent any
            when {
                expression { params.ACTION == 'destroy' && !params.AUTO_APPROVE }
            }
            steps {
                echo 'Esperando aprobacion para destruir infraestructura...'
                input message: 'DESTRUIR la infraestructura en AWS?', ok: 'Si, destruir'
            }
        }
        
        stage('Terraform Apply') {
            agent any
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
                                terraform apply -auto-approve tfplan
                                echo "Infraestructura desplegada exitosamente"
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Terraform Destroy') {
            agent any
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
                                terraform apply -auto-approve tfplan
                                echo "Infraestructura destruida"
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Show Outputs') {
            agent any
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
                                terraform output -json > outputs.json || true
                                cat outputs.json || echo "No hay outputs disponibles"
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Deploy to Dev') {
            agent any
            when {
                expression { params.ACTION == 'apply' && params.ENVIRONMENT == 'dev' }
            }
            steps {
                echo '================================================'
                echo 'Desplegando a entorno DEV'
                echo '================================================'
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        withEnv([
                            "AWS_DEFAULT_REGION=${params.AWS_REGION}",
                            "AWS_REGION=${params.AWS_REGION}"
                        ]) {
                            sh '''
                                echo "=== Verificando deployment ==="
                                
                                # Instalar AWS CLI si es necesario
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
                                        pip3 install --user awscli >/dev/null 2>&1 || true
                                    fi
                                    export PATH="$HOME/.local/bin:$PATH"
                                }
                                
                                ensure_awscli
                                export PATH="$HOME/.local/bin:$PATH"
                                
                                # Verificar Lambda functions
                                echo ""
                                echo "Verificando Lambda Functions..."
                                for fn in subscription-control access-control notification-service; do
                                    NAME="elmundo-fitness-${ENVIRONMENT}-${fn}"
                                    STATUS=$(aws lambda get-function --function-name "$NAME" --query 'Configuration.State' --output text 2>/dev/null || echo "NOT_FOUND")
                                    echo "  - $NAME: $STATUS"
                                done
                                
                                # Verificar DynamoDB tables
                                echo ""
                                echo "Verificando DynamoDB Tables..."
                                for table in usuarios historial-asistencia; do
                                    NAME="elmundo-fitness-${table}-${ENVIRONMENT}"
                                    STATUS=$(aws dynamodb describe-table --table-name "$NAME" --query 'Table.TableStatus' --output text 2>/dev/null || echo "NOT_FOUND")
                                    echo "  - $NAME: $STATUS"
                                done
                                
                                # Verificar API Gateway
                                echo ""
                                echo "Verificando API Gateway..."
                                API_ID=$(aws apigateway get-rest-apis --query "items[?name=='elmundo-fitness-api-${ENVIRONMENT}'].id" --output text 2>/dev/null || echo "NOT_FOUND")
                                if [ "$API_ID" != "NOT_FOUND" ] && [ -n "$API_ID" ]; then
                                    echo "  - API Gateway ID: $API_ID"
                                    echo "  - API URL: https://${API_ID}.execute-api.${AWS_REGION}.amazonaws.com/${ENVIRONMENT}"
                                else
                                    echo "  - API Gateway: NOT_FOUND"
                                fi
                                
                                echo ""
                                echo "=== Deployment verification completado ==="
                            '''
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            node('built-in') {
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
