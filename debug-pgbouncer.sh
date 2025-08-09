#!/bin/bash
# debug-pgbouncer.sh - Script específico para diagnosticar el problema de DNS

echo "🔍 DIAGNÓSTICO ESPECÍFICO FORO-DEPLOY"
echo "===================================="

# 1. Verificar que los contenedores están en la misma red
echo "🌐 1. VERIFICANDO RED DOCKER:"
echo "------------------------------"
docker network ls | grep foro
echo ""
docker network inspect foro_network | grep -A5 -B5 "pgbouncer\|postgres"

echo ""
echo "🐳 2. ESTADO DE CONTENEDORES:"
echo "------------------------------"
docker-compose ps

echo ""
echo "🔍 3. TEST DE DNS DESDE PGBOUNCER:"
echo "----------------------------------"
echo "🧪 Test: ¿Puede PgBouncer resolver 'postgres'?"
docker-compose exec pgbouncer nslookup postgres 2>/dev/null || echo "❌ DNS FALLA"

echo "🧪 Test: ¿Puede PgBouncer hacer ping a postgres?"
docker-compose exec pgbouncer ping -c 2 postgres 2>/dev/null || echo "❌ PING FALLA"

echo "🧪 Test: ¿Puede PgBouncer conectar al puerto 5432?"
docker-compose exec pgbouncer nc -z postgres 5432 && echo "✅ Puerto 5432 accesible" || echo "❌ Puerto 5432 inaccesible"

echo ""
echo "🔍 4. TEST DE DNS DESDE BACKEND:"
echo "--------------------------------"
echo "🧪 Test: ¿Puede Backend resolver 'postgres'?"
docker-compose exec backend nslookup postgres 2>/dev/null || echo "❌ Backend no puede resolver postgres"

echo "🧪 Test: ¿Puede Backend resolver 'pgbouncer'?"
docker-compose exec backend nslookup pgbouncer 2>/dev/null || echo "❌ Backend no puede resolver pgbouncer"

echo ""
echo "🔍 5. CONFIGURACIÓN DE PGBOUNCER:"
echo "---------------------------------"
echo "📋 Archivo pgbouncer.ini actual:"
docker-compose exec pgbouncer cat /etc/pgbouncer/pgbouncer.ini 2>/dev/null || echo "❌ No se puede leer configuración"

echo ""
echo "🔍 6. LOGS ESPECÍFICOS DEL ERROR:"
echo "---------------------------------"
echo "📋 Últimos errores de PgBouncer:"
docker-compose logs pgbouncer 2>/dev/null | grep -i "error\|warning\|dns\|failed" | tail -10

echo ""
echo "🔍 7. TEST DE CONEXIÓN DIRECTA:"
echo "-------------------------------"
echo "🧪 Test: PostgreSQL directo desde host"
if docker-compose exec postgres pg_isready -U foro_user -d forumDB; then
    echo "✅ PostgreSQL responde correctamente"
    
    echo "🧪 Test: Conexión directa desde host al contenedor"
    if psql "postgresql://foro_user:mi_password_super_seguro_123@localhost:5432/forumDB" -c "SELECT 1;" 2>/dev/null; then
        echo "✅ Conexión directa funciona"
    else
        echo "⚠️  psql no disponible en host, pero PostgreSQL responde"
    fi
else
    echo "❌ PostgreSQL no responde"
fi

echo ""
echo "🔧 8. SOLUCIONES RECOMENDADAS:"
echo "==============================="

# Verificar si hay problemas específicos
if ! docker-compose exec pgbouncer nslookup postgres >/dev/null 2>&1; then
    echo "❌ PROBLEMA: DNS no funciona desde PgBouncer"
    echo "💡 SOLUCIÓN 1: Recrear la red docker"
    echo "   docker-compose down && docker-compose up -d"
    echo ""
    echo "💡 SOLUCIÓN 2: Usar IP en lugar de nombre"
    echo "   Cambiar DATABASES_HOST de 'postgres' a IP específica"
    echo ""
fi

if ! docker-compose exec pgbouncer nc -z postgres 5432 >/dev/null 2>&1; then
    echo "❌ PROBLEMA: PgBouncer no puede conectar al puerto PostgreSQL"
    echo "💡 SOLUCIÓN: Verificar que postgres esté healthy antes de iniciar pgbouncer"
    echo ""
fi

# Verificar logs de PgBouncer para errores específicos
if docker-compose logs pgbouncer 2>/dev/null | grep -q "auth_type.*any"; then
    echo "❌ PROBLEMA: auth_type está en 'any' en lugar de 'md5'"
    echo "💡 SOLUCIÓN: Cambiar AUTH_TYPE=md5 en docker-compose.yml"
    echo ""
fi

echo "🚀 PASOS PARA SOLUCIONAR:"
echo "========================="
echo "1. Parar todos los servicios: docker-compose down"
echo "2. Aplicar docker-compose.yml corregido"
echo "3. Reiniciar: docker-compose up -d"
echo "4. Ejecutar este script de nuevo para verificar"