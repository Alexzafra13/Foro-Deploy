# 🏗️ Foro - Sistema de Despliegue Completo

Sistema de despliegue unificado para el foro completo (Backend + Frontend + Base de datos) usando Docker Compose.

## 🎯 ¿Qué incluye?

- **Backend API**: Node.js + TypeScript + PostgreSQL
- **Frontend**: React + Vite + Nginx  
- **Base de datos**: PostgreSQL + PgBouncer
- **Configuración automática** para diferentes entornos

## 🚀 Despliegue Rápido

### Opción 1: Desarrollo Local
```bash
git clone https://github.com/TU_USUARIO/foro-deploy.git
cd foro-deploy
chmod +x *.sh
./deploy-local.sh
```
**Resultado**: Accesible en http://localhost:9050

### Opción 2: Servidor de Casa (Auto-detecta IP)
```bash
./deploy-server.sh
```
**Resultado**: Accesible desde cualquier dispositivo en tu red

### Opción 3: IP Personalizada
```bash
./deploy-custom.sh 192.168.1.100
```

## ⚙️ Configuración

### 1. Archivo de Configuración
```bash
# Copiar y personalizar
cp .env.example .env
nano .env
```

### 2. Variables Importantes
```bash
# IP donde se despliega
SERVER_IP=localhost          # Para desarrollo
SERVER_IP=192.168.1.100     # Para red local  
SERVER_IP=tu-ip-publica     # Para VPS

# Puertos
API_PORT=9090
FRONTEND_PORT=9050

# Seguridad (⚠️ CAMBIAR EN PRODUCCIÓN)
JWT_SECRET=tu-jwt-secret
POSTGRES_PASSWORD=tu-password
```

## 🌐 Acceso

| Servicio | URL Local | URL Red Local |
|----------|-----------|---------------|
| **Frontend** | http://localhost:9050 | http://192.168.1.X:9050 |
| **Backend API** | http://localhost:9090 | http://192.168.1.X:9090 |
| **Base de Datos** | localhost:5432 | 192.168.1.X:5432 |

## 📱 Acceso Multi-dispositivo

Una vez desplegado en tu servidor, puedes acceder desde:
- **PC**: http://IP-SERVIDOR:9050
- **Móvil**: http://IP-SERVIDOR:9050  
- **Tablet**: http://IP-SERVIDOR:9050

## 🛠️ Comandos Útiles

```bash
# Ver estado de servicios
docker-compose ps

# Ver logs
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f frontend
docker-compose logs -f backend

# Parar servicios
./stop.sh

# Actualizar a últimas versiones
./update.sh

# Reiniciar un servicio
docker-compose restart frontend
```

## 🔧 Mantenimiento

### Actualizar Frontend
```bash
# El desarrollador actualiza la imagen
docker pull alexzafra13/foro-frontend:latest
docker-compose restart frontend
```

### Actualizar Backend
```bash
# El desarrollador actualiza la imagen  
docker pull alexzafra13/foro-api:latest
docker-compose restart backend
```

### Backup de Base de Datos
```bash
# Crear backup
docker-compose exec postgres pg_dump -U foro_user forumDB > backup.sql

# Restaurar backup
docker-compose exec -T postgres psql -U foro_user forumDB < backup.sql
```

## 🐛 Solución de Problemas

### Frontend no carga
```bash
# Verificar logs
docker-compose logs frontend

# Verificar que Nginx está corriendo
docker-compose exec frontend nginx -t
```

### Backend no responde  
```bash
# Verificar logs
docker-compose logs backend

# Verificar conexión a base de datos
docker-compose exec backend curl localhost:3000/health
```

### Error de CORS
- Verificar que `SERVER_IP` en `.env` sea correcta
- Verificar que `ALLOWED_ORIGINS` incluya la URL correcta

### No se puede acceder desde otros dispositivos
- Verificar que `SERVER_IP` sea la IP correcta de red local
- Verificar firewall del servidor
- Probar: `ping IP-SERVIDOR` desde otro dispositivo

## 📊 Arquitectura

```
Internet/Red Local
        ↓
[Puerto 9050] → Frontend (Nginx) → Archivos React
        ↓
[Puerto 9090] → Backend (Node.js) → API REST
        ↓  
[Puerto 5432] → PostgreSQL + PgBouncer → Base de Datos
```

## 🔒 Seguridad

### Para Producción:
1. **Cambiar passwords**: Editar `.env` con valores seguros
2. **Generar JWT secret**: `openssl rand -hex 32`
3. **Configurar email**: Para verificación de cuentas
4. **Firewall**: Abrir solo puertos necesarios
5. **SSL/HTTPS**: Usar reverse proxy (Nginx, Traefik)

## 📋 Requisitos

- Docker y Docker Compose instalados
- Puertos 9050 y 9090 disponibles  
- Al menos 1GB RAM libre
- 2GB espacio en disco

## 🆘 Soporte

- **Issues**: [GitHub Issues](https://github.com/TU_USUARIO/foro-deploy/issues)
- **Backend**: [Repo Backend](https://github.com/TU_USUARIO/foro-backend) 
- **Frontend**: [Repo Frontend](https://github.com/TU_USUARIO/foro-frontend)

---

**Desarrollado con ❤️ usando Docker + Node.js + React**