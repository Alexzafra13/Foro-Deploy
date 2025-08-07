#!/bin/bash
# stop.sh - Parar todos los servicios

echo "🛑 Parando servicios del foro..."
docker-compose down

echo "📋 Para eliminar también los datos:"
echo "   docker-compose down -v"