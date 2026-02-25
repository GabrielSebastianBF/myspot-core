# MySpot Core

Fork funcional de OpenClaw - Núcleo en Ruby on Rails para el producto MySpot.

## Requisitos

- Ruby >= 3.2
- PostgreSQL 15+ con extensión pgvector
- Redis (para ActionCable y Sidekiq)
- Node.js (para imports y assets)

## Setup

```bash
# 1. Clonar el repositorio
git clone https://github.com/GabrielSebastianBF/myspot-core.git
cd myspot-core

# 2. Instalar dependencias
bundle install

# 3. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# 4. Crear base de datos
rails db:create db:migrate

# 5. Iniciar servidor
rails server
```

## Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| DB_HOST | Host de PostgreSQL | localhost |
| DB_USERNAME | Usuario de PostgreSQL | myspot |
| DB_PASSWORD | Password de PostgreSQL | - |
| OPENCLAW_URL | URL del servicio OpenClaw Lite | http://localhost:3001 |
| OPENCLAW_API_KEY | API Key para OpenClaw | - |
| RAILS_SECRET_KEY_BASE | Clave secreta de Rails | - |

## Arquitectura

```
MySpot Core (Rails) <--WebSocket/API--> OpenClaw Lite (Node.js)
```

## API Endpoints

- `POST /api/agents` - Crear agente
- `GET /api/agents/:id` - Ver agente
- `POST /api/agents/:id/chat` - Enviar mensaje
- `GET /api/agents/:id/memories` - Ver memorias
- `POST /api/tools/:id/execute` - Ejecutar herramienta
- `POST /api/tools/:id/approve` - Aprobar ejecución

## Licencia

MIT
