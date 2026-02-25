# MySpot Core

Fork funcional de OpenClaw - Producto completo de **MySpot** para ITLab.

## Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                         MySpot Core (Rails 8)                    │
│    Web UI + API + Memory Engine + Tool Proxy + HITL            │
└─────────────────────────────────────────────────────────────────┘
                              ↕ API / WebSocket
┌─────────────────────────────────────────────────────────────────┐
│                    MySpot Gateway (Node.js)                     │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌─────────────┐ │
│  │ Telegram │  │Heartbeat │  │    Cron    │  │  Tools      │ │
│  │ Channel  │  │ Monitor  │  │  (Jobs)    │  │  Executor   │ │
│  └──────────┘  └──────────┘  └────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
                    ┌──────────────────┐
                    │   OpenRouter     │
                    │  (MiniMax/Gemini)│
                    └──────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│              Ollama (Embeddings Local)                          │
│         nomic-embed-text (~500MB, SIN COSTO)                   │
└─────────────────────────────────────────────────────────────────┘
```

##quick Start (Docker Compose)

```bash
# 1. Clonar
git clone https://github.com/GabrielSebastianBF/myspot-core.git
cd myspot-core

# 2. Iniciar todo
docker-compose up -d

# 3. Esperar que Ollama descargue el modelo (primera vez)
# Ver logs: docker-compose logs -f ollama

# 4. Setup base de datos
docker-compose exec myspot rails db:create db:migrate
docker-compose exec myspot rails db:seed
```

## Servicios

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| MySpot Core (Rails) | 3000 | API, Web UI, Memoria |
| MySpot Gateway | 3001 | Gateway de OpenClaw modificado |
| PostgreSQL | 5432 | Base de datos + pgvector |
| Redis | 6379 | Cache, Jobs, WebSocket |
| Ollama | 11434 | Embeddings locales |

## Variables de Entorno

### MySpot Core
```bash
DB_HOST=postgres
DB_USERNAME=myspot
DB_PASSWORD=***
OLLAMA_URL=http://ollama:11434
OLLAMA_EMBED_MODEL=nomic-embed-text
MYSPOT_API_KEY=myspot_secret_key
```

### MySpot Gateway
```bash
MYSPOT_MODE=true
MYSPOT_NAME=myspot
MYSPOT_API_URL=http://myspot:3000
DEFAULT_MODEL=minimax/MiniMax-M2.5

# Features
HEARTBEAT_ENABLED=true   # ✅ Monitoreo activo
CRON_ENABLED=true        # ✅ Jobs programados
CHANNELS_TELEGRAM_ENABLED=true

# Desactivados
NODES_ENABLED=false
CANVAS_ENABLED=false
A2UI_ENABLED=false
```

## Ollama - Embeddings Locales

```bash
# Ver estado
docker-compose logs -f ollama

# Ver modelos descargados
docker-compose exec ollama ollama list

# Modelo: nomic-embed-text (~500MB RAM)
```

**Costo:** $0 - Sin APIs externas para embeddings

## Heartbeats y Cron

Los **heartbeats** y jobs programados **se mantienen en el Gateway** (Node.js):

- `HEARTBEAT_ENABLED=true` - Monitoreo proactivo
- `CRON_ENABLED=true` - Tareas programadas

**Implementación en Ruby** (Sidekiq) queda para fase posterior si se necesita más control.

## API Endpoints

- `POST /api/agents` - Crear agente
- `POST /api/agents/:id/chat` - Chat
- `GET /api/agents/:id/memories` - Memorias
- `POST /api/tools/:id/execute` - Ejecutar herramienta
- `POST /api/tools/:id/approve` - Aprobar (HITL)
- `WS /cable` - WebSocket

## Desarrollo Local

```bash
# Instalar dependencias
bundle install

# PostgreSQL con pgvector
brew install postgresql@15
psql -c "CREATE EXTENSION IF NOT EXISTS vector;"

# Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama serve
ollama pull nomic-embed-text

# Iniciar
cp .env.example .env
rails db:create db:migrate db:seed
rails server
```

## Licencia

MIT - ITLab 2026
