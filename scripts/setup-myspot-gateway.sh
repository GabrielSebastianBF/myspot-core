#!/bin/bash
# Script para inicializar MySpot Gateway (OpenClaw modificado)
# Ejecutar desde el directorio de OpenClaw

set -e

echo "🚀 Configurando MySpot Gateway..."

# 1. Verificar que estamos en un entorno OpenClaw
if [ ! -f "package.json" ]; then
    echo "❌ Error: No se encontró package.json. Ejecuta desde el directorio de OpenClaw."
    exit 1
fi

# 2. Configurar variables de entorno para MySpot
cat > .env.myspot << 'EOF'
# ============================================
# MySpot Gateway Configuration
# ============================================

# Modo MySpot activo
MYSPOT_MODE=true
MYSPOT_NAME=myspot

# Conexión con MySpot Core (Rails)
MYSPOT_API_URL=http://localhost:3000
MYSPOT_API_KEY=myspot_secret_key

# Modelo por defecto
DEFAULT_MODEL=minimax/MiniMax-M2.5

# ============================================
# FEATURES - ACTIVOS
# ============================================

# Canales de comunicación
CHANNELS_TELEGRAM_ENABLED=true
CHANNELS_SIGNAL_ENABLED=false
CHANNELS_WHATSAPP_ENABLED=false

# Heartbeats y Cron - SÍ los necesitamos
HEARTBEAT_ENABLED=true
CRON_ENABLED=true

# ============================================
# FEATURES - DESACTIVADOS (no los usamos)
# ============================================

# Nodos remotos - NO
NODES_ENABLED=false

# Canvas/A2UI - NO
CANVAS_ENABLED=false
A2UI_ENABLED=false

# ============================================
# HERRAMIENTAS PERMITIDAS (Whitelist)
# ============================================

TOOLS_ALLOWED=exec,message,read,write,web_fetch,web_search,memory_get,memory_search,tts,image
EOF

echo "✅ Archivo .env.myspot creado"

# 3. Crear script de inicio
cat > scripts/start-myspot.sh << 'SCRIPT'
#!/bin/bash
# Iniciar MySpot Gateway

export MYSPOT_MODE=true
export NODE_ENV=production

echo "🚀 Iniciando MySpot Gateway..."
echo "   API URL: $MYSPOT_API_URL"
echo "   Modelo: $DEFAULT_MODEL"
echo "   Heartbeats: $HEARTBEAT_ENABLED"
echo "   Cron: $CRON_ENABLED"

# Iniciar gateway
./openclaw gateway start
SCRIPT

chmod +x scripts/start-myspot.sh

echo "✅ Script de inicio creado: scripts/start-myspot.sh"

# 4. Resumen
echo ""
echo "📋 MySpot Gateway Configuration:"
echo "   ============================================"
echo "   ✅ ACTIVO:"
echo "      - Telegram"
echo "      - Heartbeats"
echo "      - Cron (para heartbeats)"
echo "   ❌ DESACTIVADO:"
echo "      - Nodes (no lo necesitamos)"
echo "      - Canvas"
echo "      - A2UI"
echo "   ===================================="
echo ""
echo "⚠️  Para aplicar cambios:"
echo "   source .env.myspot"
echo "   ./scripts/start-myspot.sh"
