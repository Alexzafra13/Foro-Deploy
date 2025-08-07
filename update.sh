#!/bin/bash  
# update.sh - Actualizar a las últimas versiones

echo "🔄 Actualizando foro a las últimas versiones..."

# Parar servicios
docker-compose down

# Descargar últimas imágenes
echo "📥 Descargando últimas versiones..."
docker pull alexzafra13/foro-api:latest
docker pull alexzafra13/foro-frontend:latest

# Levantar con imágenes actualizadas
echo "🚀 Reiniciando con nuevas versiones..."
docker-compose up -d

echo "✅ Actualización completada"