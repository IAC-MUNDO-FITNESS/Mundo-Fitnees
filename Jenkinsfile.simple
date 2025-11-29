pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Action to perform'
        )
        string(
            name: 'ENVIRONMENT',
            defaultValue: 'dev',
            description: 'Target environment'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                powershell 'terraform init -input=false'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (params.ACTION == 'destroy') {
                        powershell "terraform plan -destroy -var='environment=${params.ENVIRONMENT}' -out=tfplan -input=false"
                    } else {
                        powershell "terraform plan -var='environment=${params.ENVIRONMENT}' -out=tfplan -input=false"
                    }
                }
                powershell 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
            steps {
                input message: "Do you want to proceed with ${params.ACTION}?", ok: 'Yes, proceed'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                powershell 'terraform apply -input=false -auto-approve tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                powershell 'terraform apply -input=false -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            powershell 'if (Test-Path tfplan) { Remove-Item tfplan -Force }'
        }
    }
}
