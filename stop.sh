#!/bin/bash
# stop.sh - Parar servicios del foro

echo "🛑 Parando servicios del foro..."
docker-compose down

echo "✅ Servicios parados"
echo ""
echo "💡 Para iniciar de nuevo: ./deploy.sh"
echo "🗑️  Para eliminar datos: docker-compose down -v"