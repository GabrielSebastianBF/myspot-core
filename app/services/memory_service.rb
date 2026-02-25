# frozen_string_literal: true

require 'openai'

class MemoryService
  # Servicio para gestionar memorias con embeddings semánticos
  
  def initialize(agent:)
    @agent = agent
    @openai_client = OpenAI::Client.new(
      api_key: ENV.fetch('OPENAI_API_KEY', nil)
    )
  end

  # Crear un embedding para texto
  def create_embedding(text)
    response = @openai_client.embeddings(
      model: 'text-embedding-3-small',
      input: text
    )
    
    # Retorna array de floats
    response.dig('data', 0, 'embedding')
  end

  # Buscar memorias similares usando pgvector
  def search_similar(query, limit: 5, memory_types: nil)
    query_embedding = create_embedding(query)
    
    memories = Memory.where(agent: @agent)
    memories = memories.where(memory_type: memory_types) if memory_types.present?
    
    # Búsqueda por similitud coseno (pgvector)
    memories.order(
      "embedding <=> #{query_embedding.to_s.gsub('[', '(').gsub(']', ')')}"
    ).limit(limit)
  end

  # Agregar nueva memoria con embedding automático
  def store(content, memory_type: :short, importance: 1, tags: [], session: nil)
    embedding = create_embedding(content)
    
    Memory.create!(
      agent: @agent,
      session: session,
      content: content,
      memory_type: memory_type,
      importance: importance,
      tags: tags,
      embedding: embedding
    )
  end

  # Consolidar memorias de corto plazo a largo plazo
  def consolidate_short_term
    # Mover memorias importance >= 3 a largo plazo
    Memory.where(
      agent: @agent,
      memory_type: :short,
      importance: [3, 4]
    ).update_all(memory_type: :long)
  end

  # Obtener contexto para el modelo (SCC-HDF)
  def get_context_for_prompt(max_tokens: 2000)
    context_parts = []
    
    # 1. Episodios recientes (últimas 3 sesiones)
    recent = @agent.memories
      .where(memory_type: :episodic)
      .order(created_at: :desc)
      .limit(10)
    
    context_parts << "## Episodios Recientes\n"
    context_parts << recent.map { |m| "- #{m.content}" }.join("\n")
    
    # 2. Memoria a largo plazo importante
    important = @agent.memories
      .where(memory_type: :long)
      .where('importance >= ?', 2)
      .order(importance: :desc)
      .limit(20)
    
    context_parts << "\n## Memoria a Largo Plazo\n"
    context_parts << important.map { |m| "- #{m.content}" }.join("\n")
    
    # 3. Conocimiento semántico
    semantic = @agent.memories
      .where(memory_type: :semantic)
      .limit(10)
    
    context_parts << "\n## Conocimiento\n"
    context_parts << semantic.map { |m| "- #{m.content}" }.join("\n")
    
    context_parts.join("\n\n")
  end
end
