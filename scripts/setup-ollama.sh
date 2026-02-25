#!/bin/bash
# Script para iniciar Ollama y descargar modelo de embedding
# Ejecutar una vez al inicio o manualmente

set -e

echo "🚀 Iniciando Ollama..."

# Iniciar Ollama en background
if command -v ollama &> /dev/null; then
    ollama serve &
    OLLAMA_PID=$!
    
    # Esperar que inicie
    sleep 3
    
    echo "📥 Descargando modelo de embedding: nomic-embed-text (~500MB)"
    ollama pull nomic-embed-text
    
    echo "✅ Modelo descargado"
    echo "📊 Modelos disponibles:"
    ollama list
    
    echo ""
    echo "🎯 Ollama listo en http://localhost:11434"
else
    echo "❌ Ollama no está instalado"
    echo "   Instalar con: curl -fsSL https://ollama.com/install.sh | sh"
fi
