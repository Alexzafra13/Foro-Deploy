#!/bin/bash
# deploy-server.sh - Despliegue para servidor (detecta IP automáticamente)

set -e

echo "🏡 Desplegando FORO completo en SERVIDOR..."

# Detectar IP automáticamente
SERVER_IP=$(hostname -I | awk '{print $1}')

if [ -z "$SERVER_IP" ]; then
    echo "❌ No se pudo detectar la IP automáticamente"
    echo "📝 Usa: ./deploy-custom.sh TU_IP"
    exit 1
fi

echo "📡 IP detectada: $SERVER_IP"

# Verificar archivo .env
if [ ! -f .env ]; then
    echo "⚠️  No se encontró archivo .env"
    echo "📋 Copiando .env.example como .env..."
    cp .env.example .env
    
    # Actualizar SERVER_IP en .env automáticamente
    sed -i "s/SERVER_IP=localhost/SERVER_IP=$SERVER_IP/" .env
    
    echo "✏️  Archivo .env creado con IP: $SERVER_IP"
    echo "📝 Revisa y edita el archivo .env si es necesario"
fi

# Exportar la IP para docker-compose
export SERVER_IP=$SERVER_IP

echo "🔧 Configuración:"
echo "   Frontend: http://$SERVER_IP:9050"
echo "   Backend:  http://$SERVER_IP:9090"
echo "   Accesible desde cualquier dispositivo en la red"

# Parar contenedores existentes
echo "🛑 Parando contenedores existentes..."
docker-compose down

# Descargar imágenes más recientes
echo "📥 Descargando imágenes más recientes..."
docker pull alexzafra13/foro-api:latest
docker pull alexzafra13/foro-frontend:latest

# Levantar servicios
echo "🚀 Levantando servicios..."
docker-compose up -d

# Esperar a que estén saludables
echo "⏳ Esperando que los servicios estén listos..."
sleep 30

# Verificar estado
echo "🔍 Verificando estado de servicios..."
docker-compose ps

echo ""
echo "🎉 ¡Despliegue completado!"
echo ""
echo "🌐 Acceso desde dispositivos en la red:"
echo "   Frontend: http://$SERVER_IP:9050"
echo "   Backend:  http://$SERVER_IP:9090"
echo ""
echo "📱 Prueba desde móvil/tablet: http://$SERVER_IP:9050"
echo "📋 Para ver logs: docker-compose logs -f"