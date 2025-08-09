# 🚀 Foro - Instalación Automática

Sistema de foro completo con instalación de un solo comando, como Jellyfin o Portainer.

## ⚡ Instalación Rápida

```bash
# 1. Clonar repositorio
git clone https://github.com/alexzafra/foro-deploy.git
cd foro-deploy

# 2. Instalar automáticamente
chmod +x *.sh
./deploy.sh

# ✅ ¡Ya funciona!
# Acceso: http://TU-IP:9050
```

## 🎯 Características

- ✅ **Instalación automática** - Sin configuración previa
- 🧠 **Auto-detección de IP** - Funciona en cualquier red
- 🔐 **Passwords seguros** auto-generados
- 📧 **Email funcional** por defecto (personalizable)
- 🔄 **PgBouncer con fallback** automático
- 📱 **Acceso multi-dispositivo** inmediato

## 👤 Usuarios Creados

| Usuario | Email | Password | Rol |
|---------|-------|----------|-----|
| Admin | admin@foro.local | admin123 | Administrador |
| Moderador | mod@foro.local | admin123 | Moderador |
| Usuario | user@foro.local | admin123 | Usuario |

## ⚙️ Personalización

```bash
# Editar configuración (opcional)
nano .env

# Aplicar cambios
./deploy.sh

# Parar servicios
./stop.sh
```

## 📧 Configurar Email

```bash
# 1. Editar .env
MAILER_EMAIL=tu-email@gmail.com
MAILER_SECRET_KEY=tu_contraseña_de_aplicacion

# 2. Aplicar cambios
./deploy.sh
```

## 🔧 Comandos Útiles

```bash
docker-compose ps          # Ver estado
docker-compose logs -f     # Ver logs
docker-compose restart backend  # Reiniciar servicio
```

## 📋 Requisitos

- Docker y Docker Compose
- Puerto 9050 disponible
- 1GB RAM mínimo