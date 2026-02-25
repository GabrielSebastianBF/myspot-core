# MySpot Core

Fork funcional de OpenClaw - Núcleo en **Ruby on Rails 8** para el producto MySpot.

##quick Start (Docker)

La forma más fácil de levantar todo:

```bash
# 1. Clonar y entrar
git clone https://github.com/GabrielSebastianBF/myspot-core.git
cd myspot-core

# 2. Iniciar todo (PostgreSQL + Redis + Rails + OpenClaw)
docker-compose up -d

# 3. Setup base de datos
docker-compose exec myspot rails db:create db:migrate
docker-compose exec myspot rails db:seed
```

## Desarrollo Local (Sin Docker)

### Requisitos

- Ruby >= 3.2
- PostgreSQL 15+ con extensión **pgvector**
- Redis (para ActionCable y Sidekiq)
- Node.js (para imports y assets)
- **Ollama** ejecutándose en puerto 11434

### Setup

```bash
# 1. Clonar el repositorio
git clone https://github.com/GabrielSebastianBF/myspot-core.git
cd myspot-core

# 2. Instalar dependencias
bundle install

# 3. Asegúrate que Ollama esté corriendo
ollama serve
ollama pull nomic-embed-text

# 4. Configurar PostgreSQL con pgvector
# brew install postgresql@15
# psql -c "CREATE EXTENSION IF NOT EXISTS vector;" tu_db

# 5. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# 6. Crear base de datos
rails db:create db:migrate

# 7. Semillas (datos iniciales)
rails db:seed

# 8. Iniciar servidor
rails server
```

## Ollama (Embeddings Locales)

```bash
# Verificar que esté corriendo
ollama list

# Descargar modelo de embedding (una vez)
ollama pull nomic-embed-text

# El modelo ocupa ~500MB en RAM
```

## Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| DB_HOST | Host de PostgreSQL | localhost |
| DB_USERNAME | Usuario de PostgreSQL | myspot |
| DB_PASSWORD | Password de PostgreSQL | - |
| OLLAMA_URL | URL de Ollama | http://localhost:11434 |
| OLLAMA_EMBED_MODEL | Modelo de embedding | nomic-embed-text |
| OPENCLAW_URL | URL del servicio OpenClaw Lite | http://localhost:3001 |
| OPENCLAW_API_KEY | API Key para OpenClaw | - |
| REDIS_URL | URL de Redis | redis://localhost:6379 |

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    MySpot Core (Rails 8)                      │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  Web UI     │  │  API Layer   │  │  Memory Engine   │   │
│  │  (Dash)    │  │  (REST/WS)   │  │  (PostgreSQL)    │   │
│  └─────────────┘  └──────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (WebSocket/API)
┌─────────────────────────────────────────────────────────────┐
│              OpenClaw Lite (Motor Node.js)                   │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  Gateway    │  │  Tool        │  │  LLM Connector   │   │
│  │  (Orquest)  │  │  Executor    │  │  (OpenRouter)    │   │
│  └─────────────┘  └──────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                         Ollama (Embeddings)
```

## API Endpoints

- `POST /api/agents` - Crear agente
- `GET /api/agents/:id` - Ver agente
- `POST /api/agents/:id/chat` - Enviar mensaje
- `GET /api/agents/:id/memories` - Ver memorias
- `POST /api/tools/:id/execute` - Ejecutar herramienta
- `POST /api/tools/:id/approve` - Aprobar ejecución (HITL)
- `WS /cable` - WebSocket para chat en tiempo real

## WebSocket (JavaScript Client)

```javascript
const cable = ActionCable.createConsumer('ws://localhost:3000/cable');
const channel = cable.subscriptions.create('AgentChannel', {
  agent_id: 'uuid-del-agente'
});

channel.on('message', (data) => {
  console.log('Nueva respuesta:', data.message);
});

// Enviar mensaje
channel.perform('chat', { message: 'Hola Spot' });
```

## Licencia

MIT
