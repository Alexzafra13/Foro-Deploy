#!/bin/bash
# deploy-local.sh - Despliegue para desarrollo local

set -e

echo "🏠 Desplegando FORO completo en LOCAL..."

# Verificar que existe el archivo .env
if [ ! -f .env ]; then
    echo "⚠️  No se encontró archivo .env"
    echo "📋 Copiando .env.example como .env..."
    cp .env.example .env
    echo "✏️  Por favor edita el archivo .env antes de continuar"
    exit 1
fi

# Configurar para local
export SERVER_IP=localhost

echo "🔧 Configuración:"
echo "   Frontend: http://localhost:9050"
echo "   Backend:  http://localhost:9090"
echo "   Base de datos: localhost:5432"

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

# Verificar conectividad
echo "🧪 Probando conectividad..."
if curl -f http://localhost:9090/health >/dev/null 2>&1; then
    echo "✅ Backend: OK"
else
    echo "❌ Backend: Error"
fi

if curl -f http://localhost:9050/health >/dev/null 2>&1; then
    echo "✅ Frontend: OK"
else
    echo "❌ Frontend: Error"
fi

echo ""
echo "🎉 ¡Despliegue completado!"
echo "🌐 Accede al foro en: http://localhost:9050"
echo "📚 API disponible en: http://localhost:9090"
echo "📋 Para ver logs: docker-compose logs -f"