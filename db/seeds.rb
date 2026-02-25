# frozen_string_literal: true

# Semillas iniciales para MySpot

puts "🌱 Creating initial data..."

# 1. Crear agente Spot (el agente principal)
spot = Agent.create!(
  name: 'Spot',
  role: 'assistant',
  config: {
    temperature: 0.7,
    max_tokens: 4096,
    system_prompt: <<~PROMPT
      You are Spot, a helpful AI assistant created by ITLab.
      You are loyal, proactive, and technically rigorous.
      You help Gabriel (Lemut) with his projects and daily tasks.
      
      Your personality:
      - Professional but warm
      - Proactive in proposing solutions
      - Technically precise
      - Follows HITL (Human-In-The-Loop) protocol for critical decisions
    PROMPT
  },
  model_preferred: 'minimax/MiniMax-M2.5',
  active: true
)

puts "✅ Created agent: #{spot.name} (#{spot.id})"

# 2. Crear herramientas del whitelist
tools = [
  { name: 'read', description: 'Read file contents', allowed_roles: %w[assistant operator], enabled: true },
  { name: 'write', description: 'Write or create files', allowed_roles: %w[assistant operator], enabled: true },
  { name: 'exec', description: 'Execute shell commands', allowed_roles: %w[operator], enabled: true },
  { name: 'message', description: 'Send messages via channels', allowed_roles: %w[assistant operator], enabled: true },
  { name: 'web_fetch', description: 'Fetch web page content', allowed_roles: %w[assistant], enabled: true },
  { name: 'web_search', description: 'Search the web', allowed_roles: %w[assistant], enabled: true },
  { name: 'memory_get', description: 'Get memories from storage', allowed_roles: %w[assistant], enabled: true },
  { name: 'memory_search', description: 'Search memories', allowed_roles: %w[assistant], enabled: true },
  { name: 'tts', description: 'Text to speech', allowed_roles: %w[assistant], enabled: true },
  { name: 'image', description: 'Analyze images', allowed_roles: %w[assistant], enabled: true }
]

tools.each do |tool_data|
  Tool.find_or_create_by!(name: tool_data[:name]) do |tool|
    tool.description = tool_data[:description]
    tool.allowed_roles = tool_data[:allowed_roles]
    tool.enabled = tool_data[:enabled]
  end
  puts "✅ Tool: #{tool_data[:name]}"
end

# 3. Crear memorias iniciales de Spot sobre Gabriel
memories_data = [
  { content: "Gabriel Bustos (Lemut) is the owner. He's a Solutions Architect, Full Stack Developer and UX/UI expert from Chile. He's married to Loreto and has a son Ignacio (27, doctor).", memory_type: 'long', importance: 4, tags: %w[owner personal family] },
  { content: "Gabriel works at ITLab, his company. He has 25+ years of experience in tech.", memory_type: 'long', importance: 4, tags: %w[work itlab] },
  { content: "Gabriel loves F1 (fan of Fernando Alonso), Golf (follows Joaquín Niemann), RC Cars, 3D printing, electronics, DJing, and board games.", memory_type: 'semantic', importance: 3, tags: %w[hobbies sports] },
  { content: "Gabriel's phone: +56972673878. Email: gabriel@itlab.cl", memory_type: 'long', importance: 4, tags: %w[contact] },
  { content: "Spot operates with HITL protocol - always wait for Gabriel's OK before executing critical changes.", memory_type: 'semantic', importance: 4, tags: %w[protocol hitl] }
]

memories_data.each do |mem_data|
  spot.memories.create!(mem_data)
  puts "✅ Memory: #{mem_data[:content][0..50]}..."
end

puts "\n🎉 Seed completed!"
puts "   Agent: #{spot.name}"
puts "   Tools: #{Tool.count}"
puts "   Memories: #{Memory.count}"
puts "\n📝 Embeddings: Usando Ollama local (#{ENV.fetch('OLLAMA_EMBED_MODEL', 'nomic-embed-text')}) - SIN COSTO"
