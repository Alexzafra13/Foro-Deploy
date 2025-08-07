# deploy-custom.sh - Despliegue con IP personalizada

set -e

if [ -z "$1" ]; then
    echo "❌ Uso: ./deploy-custom.sh IP_DEL_SERVIDOR"
    echo ""
    echo "📝 Ejemplos:"
    echo "   ./deploy-custom.sh 192.168.1.100"
    echo "   ./deploy-custom.sh mi-servidor.local"
    echo "   ./deploy-custom.sh 203.0.113.1"
    exit 1
fi

SERVER_IP=$1

echo "🚀 Desplegando FORO con IP personalizada: $SERVER_IP"

# Verificar archivo .env
if [ ! -f .env ]; then
    echo "📋 Copiando .env.example como .env..."
    cp .env.example .env
    
    # Actualizar SERVER_IP en .env
    sed -i "s/SERVER_IP=localhost/SERVER_IP=$SERVER_IP/" .env
    echo "✏️  Archivo .env actualizado con IP: $SERVER_IP"
fi

# Exportar la IP para docker-compose
export SERVER_IP=$SERVER_IP

echo "🔧 Configuración:"
echo "   Frontend: http://$SERVER_IP:9050"
echo "   Backend:  http://$SERVER_IP:9090"

# Parar contenedores existentes
docker-compose down

# Descargar imágenes más recientes
echo "📥 Descargando imágenes más recientes..."
docker pull alexzafra13/foro-api:latest
docker pull alexzafra13/foro-frontend:latest

# Levantar servicios
docker-compose up -d

# Esperar y verificar
sleep 30
docker-compose ps

echo ""
echo "🎉 ¡Despliegue completado!"
echo "🌐 Accesible en: http://$SERVER_IP:9050"

---
#!/bin/bash
# stop.sh - Parar todos los servicios

echo "🛑 Parando servicios del foro..."
docker-compose down

echo "📋 Para eliminar también los datos:"
echo "   docker-compose down -v"