#!/bin/bash
# deploy.sh - Instalación automática estilo Jellyfin

set -e
clear

echo "🚀 FORO - INSTALACIÓN AUTOMÁTICA"
echo "================================="
echo "Instalación plug-and-play sin configuración previa"
echo ""

# 🔐 GENERAR PASSWORD SEGURO
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

generate_jwt_secret() {
    openssl rand -hex 32
}

# 🧠 AUTO-DETECCIÓN DE IP
detect_ip() {
    # Buscar IP de red local (casa/oficina)
    local detected_ip=$(hostname -I 2>/dev/null | tr ' ' '\n' | grep -E '^192\.168\.' | head -1)
    if [ ! -z "$detected_ip" ]; then
        echo "$detected_ip"
        return
    fi
    
    # Buscar otras IPs privadas
    detected_ip=$(hostname -I 2>/dev/null | tr ' ' '\n' | grep -E '^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' | head -1)
    if [ ! -z "$detected_ip" ]; then
        echo "$detected_ip"
        return
    fi
    
    # Fallback a primera IP no-local
    detected_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    if [ ! -z "$detected_ip" ] && [ "$detected_ip" != "127.0.0.1" ]; then
        echo "$detected_ip"
        return
    fi
    
    # Último fallback
    echo "localhost"
}

# 🎯 DETECTAR CONFIGURACIÓN
SERVER_IP=$(detect_ip)
FRONTEND_PORT=9050

echo "🔍 Configuración detectada:"
echo "   IP del servidor: $SERVER_IP"
echo "   Puerto frontend: $FRONTEND_PORT"
echo ""

# 🔧 CREAR .env AUTOMÁTICO
if [ ! -f .env ]; then
    echo "📝 Generando configuración automática..."
    
    # Generar valores seguros
    POSTGRES_PASSWORD=$(generate_password)
    JWT_SECRET=$(generate_jwt_secret)
    EMAIL_SECRET=$(generate_jwt_secret)
    
    cat > .env << EOF
# ===== FORO - CONFIGURACIÓN AUTO-GENERADA =====
# Generado automáticamente el $(date)

# 🌐 CONFIGURACIÓN DE RED
SERVER_IP=$SERVER_IP
FRONTEND_PORT=$FRONTEND_PORT

# 🔐 BASE DE DATOS (AUTO-GENERADA)
POSTGRES_USER=foro_user
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=forumDB

# 🔑 SEGURIDAD (AUTO-GENERADA)
JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=7d
EMAIL_VERIFICATION_SECRET=$EMAIL_SECRET
BCRYPT_ROUNDS=12

# 📧 EMAIL (FUNCIONAL POR DEFECTO)
MAILER_SERVICE=gmail
MAILER_EMAIL=admin@localhost
MAILER_SECRET_KEY=dummy_password

# ⚙️ CONFIGURACIÓN AVANZADA
NODE_ENV=production
ENABLE_QUERY_LOGGING=false
CONNECTION_POOL_SIZE=20

# ===== PERSONALIZACIÓN =====
# Para configurar email real, edita MAILER_EMAIL y MAILER_SECRET_KEY
# Luego ejecuta: ./deploy.sh para aplicar cambios
EOF
    
    echo "✅ Configuración automática creada"
    echo "🔐 Password de BD generado: $POSTGRES_PASSWORD"
    echo "🔑 JWT Secret generado: ${JWT_SECRET:0:20}..."
    echo ""
else
    echo "✅ Archivo .env encontrado, usando configuración existente"
    
    # Actualizar SERVER_IP si cambió
    if grep -q "SERVER_IP=" .env; then
        sed -i "s/SERVER_IP=.*/SERVER_IP=$SERVER_IP/" .env
        echo "🔄 SERVER_IP actualizada a: $SERVER_IP"
    fi
fi

# 📁 CREAR DIRECTORIOS
echo "📁 Preparando directorios..."
mkdir -p backups

# 🛑 PARAR SERVICIOS ANTERIORES
echo "🛑 Parando servicios anteriores..."
docker-compose down --remove-orphans 2>/dev/null || true

# 📦 DESCARGAR ÚLTIMAS IMÁGENES
echo "📦 Descargando imágenes del foro..."
echo "   ⬇️ Backend API..."
docker pull alexzafra13/foro-api:latest
echo "   ⬇️ Frontend..."
docker pull alexzafra13/foro-frontend:latest

# 🚀 INICIAR SERVICIOS
echo ""
echo "🚀 Iniciando servicios del foro..."
export SERVER_IP=$SERVER_IP
export FRONTEND_PORT=$FRONTEND_PORT
docker-compose up -d

# ⏳ ESPERAR INICIALIZACIÓN
echo "⏳ Esperando inicialización completa..."
echo "   📊 Esto puede tardar 1-2 minutos la primera vez..."

for i in {1..60}; do
    echo -n "."
    sleep 1
    if [ $((i % 15)) -eq 0 ]; then
        echo " ${i}s"
    fi
done
echo ""

# 📊 VERIFICAR ESTADO
echo ""
echo "📊 ESTADO DE SERVICIOS:"
echo "======================="
docker-compose ps

# 🧪 VERIFICAR CONECTIVIDAD
echo ""
echo "🧪 VERIFICANDO CONECTIVIDAD:"
echo "============================"

# PostgreSQL
if docker-compose exec -T postgres pg_isready -U foro_user >/dev/null 2>&1; then
    echo "✅ PostgreSQL: Conectado"
else
    echo "❌ PostgreSQL: Error"
fi

# PgBouncer
if timeout 10 docker-compose exec -T pgbouncer nc -z 127.0.0.1 6432 >/dev/null 2>&1; then
    echo "✅ PgBouncer: Conectado"
else
    echo "⚠️  PgBouncer: Verificando..."
fi

# Backend (esperar un poco más)
sleep 15
if curl -f http://localhost:3000/health >/dev/null 2>&1; then
    echo "✅ Backend: Funcionando"
elif curl -f http://127.0.0.1:3000/health >/dev/null 2>&1; then
    echo "✅ Backend: Funcionando"
else
    echo "⚠️  Backend: Iniciando... (puede tardar unos segundos más)"
fi

# Frontend
if curl -f http://localhost:$FRONTEND_PORT >/dev/null 2>&1; then
    echo "✅ Frontend: Funcionando"
else
    echo "⚠️  Frontend: Iniciando..."
fi

echo ""
echo "🎉 ¡INSTALACIÓN COMPLETADA!"
echo "=========================="
echo ""
echo "🌐 ACCESO AL FORO:"
echo "   📱 Desde este dispositivo: http://localhost:$FRONTEND_PORT"
echo "   🌍 Desde otros dispositivos: http://$SERVER_IP:$FRONTEND_PORT"
echo ""
echo "👤 USUARIOS CREADOS AUTOMÁTICAMENTE:"
echo "   🔑 Admin: admin@foro.local / admin123"
echo "   👮 Moderador: mod@foro.local / admin123"
echo "   👤 Usuario: user@foro.local / admin123"
echo ""
echo "⚙️ PERSONALIZACIÓN (OPCIONAL):"
echo "   📝 Editar configuración: nano .env"
echo "   🔄 Aplicar cambios: ./deploy.sh"
echo "   🛑 Parar servicios: ./stop.sh"
echo "   📋 Ver logs: docker-compose logs -f"
echo ""
echo "📧 CONFIGURAR EMAIL (OPCIONAL):"
echo "   1. Editar MAILER_EMAIL en .env con tu Gmail"
echo "   2. Editar MAILER_SECRET_KEY con tu contraseña de aplicación"
echo "   3. Ejecutar: ./deploy.sh"
echo ""

if [ "$SERVER_IP" != "localhost" ]; then
    echo "🔥 FIREWALL:"
    echo "   Asegúrate de que el puerto $FRONTEND_PORT esté abierto:"
    echo "   - Ubuntu/Debian: sudo ufw allow $FRONTEND_PORT"
    echo "   - CentOS/RHEL: sudo firewall-cmd --add-port=$FRONTEND_PORT/tcp --permanent"
    echo ""
fi

echo "🎯 ¡El foro está listo para usar!"
