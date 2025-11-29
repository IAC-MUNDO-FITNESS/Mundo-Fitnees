#!/bin/bash

# ============================================
# SCRIPT: INSTALAR PLUGINS EN JENKINS
# ============================================

echo "================================================"
echo "Instalando Plugins en Jenkins"
echo "================================================"

# Configuración
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_PASSWORD="ElMundoFitness2024!"

# Esperar a que Jenkins esté disponible
echo ""
echo "⏳ Esperando a que Jenkins esté disponible..."
until curl -s -o /dev/null -w "%{http_code}" "$JENKINS_URL/login" | grep -q "200"; do
    echo "   Esperando a Jenkins..."
    sleep 5
done
echo "✅ Jenkins está disponible"

# Descargar Jenkins CLI
echo ""
echo "📥 Descargando Jenkins CLI..."
wget -q "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -O jenkins-cli.jar
echo "✅ Jenkins CLI descargado"

# Lista de plugins a instalar
PLUGINS=(
    "git"
    "workflow-aggregator"
    "pipeline-stage-view"
    "credentials-binding"
    "timestamper"
    "terraform"
    "aws-credentials"
    "aws-java-sdk"
    "docker-plugin"
    "docker-workflow"
    "configuration-as-code"
    "job-dsl"
    "build-timeout"
    "ansicolor"
    "blueocean"
    "email-ext"
    "slack"
    "github"
    "junit"
)

# Instalar cada plugin
echo ""
echo "📦 Instalando plugins..."
for plugin in "${PLUGINS[@]}"; do
    echo "   Instalando $plugin..."
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" install-plugin "$plugin" -restart
done

echo ""
echo "================================================"
echo "✅ Plugins instalados exitosamente"
echo "================================================"
echo ""
echo "⚠️  Jenkins se reiniciará automáticamente"
echo "   Espera 30-60 segundos y accede a: $JENKINS_URL"
echo ""
