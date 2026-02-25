#!/bin/bash
# Script para inicializar OpenClaw Lite para MySpot
# Ejecutar desde el directorio de OpenClaw

set -e

echo "🚀 Configurando OpenClaw Lite para MySpot..."

# 1. Verificar que estamos en un entorno OpenClaw
if [ ! -f "package.json" ]; then
    echo "❌ Error: No se encontró package.json. Ejecuta desde el directorio de OpenClaw."
    exit 1
fi

# 2. Configurar variables de entorno para MySpot
cat > .env.myspot << 'EOF'
# MySpot Integration
MYSPOT_ENABLED=true
MYSPOT_API_URL=http://localhost:3000
MYSPOT_API_KEY=myspot_secret_key

# Configuración Lite (mínimo)
# Desactivar features que no usamos
ENABLE_NODES=false
ENABLE_CANVAS=false
ENABLE_A2UI=false
ENABLE_CRON=false

# Herramientas habilitadas para MySpot
TOOLS_ALLOWED=exec,message,read,write,web_fetch,web_search,memory_get,memory_search,tts,image

# Channel - solo Telegram para comenzar
CHANNELS_TELEGRAM_ENABLED=true
CHANNELS_SIGNAL_ENABLED=false
CHANNELS_WHATSAPP_ENABLED=false

# Modelo por defecto
DEFAULT_MODEL=minimax/MiniMax-M2.5
EOF

echo "✅ Archivo .env.myspot creado"

# 3. Actualizar config si existe
if [ -f "config.yaml" ]; then
    echo "📝 Actualizando config.yaml..."
    # Backup
    cp config.yaml config.yaml.backup
    
    # Agregar settings de MySpot
    cat >> config.yaml << 'EOF'
myspot:
  enabled: true
  api_url: http://localhost:3000
  api_key: myspot_secret_key
  allowed_tools:
    - read
    - write
    - exec
    - message
    - web_fetch
    - web_search
    - memory_get
    - memory_search
    - tts
    - image
lite_mode: true
EOF
fi

# 4. Crear script de inicio
cat > scripts/start-myspot.sh << 'SCRIPT'
#!/bin/bash
# Iniciar OpenClaw en modo Lite para MySpot

export MYSPOT_ENABLED=true
export NODE_ENV=production

# Iniciar gateway
./openclaw gateway start
SCRIPT

chmod +x scripts/start-myspot.sh

echo "✅ Script de inicio creado: scripts/start-myspot.sh"

# 5. Verificar status
echo ""
echo "📋 Resumen de configuración:"
echo "   - MySpot API URL: http://localhost:3000"
echo "   - Herramientas: $(echo $TOOLS_ALLOWED | tr ',' ' ')"
echo "   - Modo: Lite (sin nodes, canvas, cron)"
echo ""
echo "⚠️  Para aplicar cambios, reinicia el gateway:"
echo "   ./scripts/start-myspot.sh"
