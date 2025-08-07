# 🏗️ Foro - Sistema de Despliegue Completo

Sistema de despliegue unificado para foro completo con **PostgreSQL + PgBouncer + Backend + Frontend**.

## 🎯 ¿Qué incluye?

- **Backend API**: Node.js + TypeScript + PostgreSQL + PgBouncer
- **Frontend**: React + Vite + Nginx (proxy interno)
- **Base de datos**: PostgreSQL 17 + PgBouncer (connection pooling)
- **Inicialización automática**: Migraciones y seed en primer arranque

## 🚀 Despliegue Rápido

### Cualquier Servidor (Local, Casa, VPS)
```bash
git clone https://github.com/Alexzafra13/Foro-Deploy.git
cd Foro-Deploy
cp .env.example .env

# Editar credenciales:
nano .env

# Cambiar mínimo:
# - POSTGRES_PASSWORD
# - JWT_SECRET  
# - SERVER_IP (si no es localhost)

# Desplegar:
docker-compose up -d
```

**¡Listo!** Accede en: `http://tu-server-ip:9050`

## 🔑 Usuarios Por Defecto

El sistema crea automáticamente estos usuarios:

- **Admin**: `admin@foro.local` / `admin123`
- **Moderador**: `mod@foro.local` / `admin123`
- **Usuario**: `user@foro.local` / `admin123`

## ⚙️ Configuración por Entorno

### 🏠 Desarrollo Local
```bash
SERVER_IP=localhost
FRONTEND_PORT=9050
```
**Acceso**: http://localhost:9050

### 🏡 Servidor de Casa
```bash
SERVER_IP=192.168.1.100  # Tu IP local
FRONTEND_PORT=9050
```
**Acceso**: 
- PC: http://192.168.1.100:9050
- Móvil: http://192.168.1.100:9050

### ☁️ VPS Público
```bash
SERVER_IP=tu-ip-publica
FRONTEND_PORT=9050
```
**Acceso**: http://tu-ip-publica:9050

## 🏗️ Arquitectura

```
Internet/Red Local → [Puerto 9050]
    ↓
┌─────────────────────────────────┐
│ 🌐 Frontend (Nginx)             │
│ - Sirve React App               │
│ - Proxy /api/* → Backend        │
└─────────────────────────────────┘
    ↓ (red interna)
┌─────────────────────────────────┐
│ ⚙️ Backend (Node.js)            │
│ - API REST                      │
│ - JWT Auth                      │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│ 🔄 PgBouncer                    │
│ - Connection Pooling            │
│ - 30 conexiones por defecto     │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│ 🗃️ PostgreSQL 17               │
│ - Base de datos                 │
│ - Datos persistentes           │
└─────────────────────────────────┘
```

## 🛠️ Comandos Útiles

```bash
# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f

# Ver logs específicos
docker-compose logs frontend
docker-compose logs backend

# Reiniciar servicios
docker-compose restart backend
docker-compose restart frontend

# Parar todo
docker-compose down

# Parar y borrar datos
docker-compose down -v

# Actualizar imágenes
docker-compose pull
docker-compose up -d
```

## 🔧 Mantenimiento

### Actualizar Frontend
```bash
docker pull alexzafra13/foro-frontend:latest
docker-compose restart frontend
```

### Actualizar Backend
```bash
docker pull alexzafra13/foro-api:latest
docker-compose restart backend
```

### Backup Base de Datos
```bash
docker-compose exec postgres pg_dump -U foro_user forumDB > backup-$(date +%Y%m%d).sql
```

### Restaurar Backup
```bash
docker-compose exec -T postgres psql -U foro_user forumDB < backup-fecha.sql
```

## 🐛 Solución de Problemas

### Frontend no carga
```bash
docker-compose logs frontend
curl http://localhost:9050/health  # Debería responder "healthy"
```

### Backend error 500
```bash
docker-compose logs backend
# Verificar conexión PgBouncer:
docker-compose exec backend curl http://localhost:3000/health
```

### Error de CORS
- Verificar `SERVER_IP` en `.env` 
- Verificar `ALLOWED_ORIGINS` en logs del backend

### PgBouncer no conecta
```bash
docker-compose logs pgbouncer
# Verificar que PostgreSQL esté healthy:
docker-compose ps postgres
```

## 📊 Monitoreo

### Ver Conexiones PgBouncer
```bash
# Conectar a PgBouncer admin
docker-compose exec postgres psql -h pgbouncer -p 6432 -U foro_user pgbouncer -c "SHOW POOLS;"
```

### Ver Estadísticas DB
```bash
docker-compose exec postgres psql -U foro_user -d forumDB -c "
SELECT schemaname,tablename,n_tup_ins,n_tup_upd,n_tup_del 
FROM pg_stat_user_tables 
ORDER BY n_tup_ins DESC LIMIT 10;"
```

## 🔒 Seguridad para Producción

1. **Cambiar passwords**: Generar valores seguros en `.env`
2. **JWT secret**: `openssl rand -hex 32`
3. **Email real**: Configurar SMTP válido
4. **Firewall**: Abrir solo puerto necesario (9050)
5. **SSL/HTTPS**: Usar reverse proxy (Nginx, Traefik, Cloudflare)

## 📋 Requisitos

- **Docker**: 20.10+
- **Docker Compose**: 1.29+
- **RAM**: 1GB mínimo
- **Disco**: 2GB mínimo
- **Puertos**: 9050 libre

## 🆘 Soporte

- **Issues**: [GitHub Issues](https://github.com/Alexzafra13/Foro-Deploy/issues)
- **Backend**: [alexzafra13/foro-api](https://hub.docker.com/r/alexzafra13/foro-api)
- **Frontend**: [alexzafra13/foro-frontend](https://hub.docker.com/r/alexzafra13/foro-frontend)

---

**Desarrollado con ❤️ usando Docker + PostgreSQL + PgBouncer + Node.js + React**