# frozen_string_literal: true

class MemoryService
  # Servicio para gestionar memorias
  # Usa búsqueda semántica cuando hay embeddings disponibles (VoyageAI via OpenRouter)
  # Sin API de embeddings, usa búsqueda por texto/full-text
  
  def initialize(agent:)
    @agent = agent
  end

  # Crear embedding usando VoyageAI (OpenRouter) si está disponible
  # Si no hay API, retorna nil y usa búsqueda full-text
  def create_embedding(text)
    api_key = ENV.fetch('OPENROUTER_API_KEY', nil)
    return nil unless api_key

    begin
      uri = URI.parse('https://openrouter.ai/api/v1/embeddings')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'
      request.body = {
        model: 'voyageai/voyage-3',
        input: text
      }.to_json

      response = http.request(request)
      data = JSON.parse(response.body)
      
      data.dig('data', 0, 'embedding')
    rescue => e
      Rails.logger.warn "Embedding failed: #{e.message}"
      nil
    end
  end

  # Buscar memorias similares
  # Si hay embedding: búsqueda vectorial (pgvector)
  # Si no: búsqueda full-text con PostgreSQL
  def search_similar(query, limit: 5, memory_types: nil)
    memories = Memory.where(agent: @agent)
    memories = memories.where(memory_type: memory_types) if memory_types.present?

    # Intentar embedding si hay API
    query_embedding = create_embedding(query)
    
    if query_embedding
      # Búsqueda vectorial (pgvector)
      # Similitud coseno: embedding <=> query_embedding
      emb_str = query_embedding.to_s.gsub('[', '(').gsub(']', ')')
      memories = memories.where.not(embedding: nil)
        .order("embedding <=> #{emb_str}")
    else
      # Fallback: búsqueda por contenido
      search_term = "%#{query}%"
      memories = memories.where("content ILIKE ?", search_term)
    end

    memories.limit(limit)
  end

  # Agregar nueva memoria
  # Si hay API, genera embedding automáticamente
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
    Memory.where(
      agent: @agent,
      memory_type: :short,
      importance: [3, 4]
    ).update_all(memory_type: :long)
  end

  # Obtener contexto para el modelo (SCC-HDF)
  def get_context_for_prompt(max_tokens: 2000)
    context_parts = []

    # 1. Episodios recientes
    recent = @agent.memories
      .where(memory_type: :episodic)
      .order(created_at: :desc)
      .limit(10)
    
    context_parts << "## Episodios Recientes\n"
    context_parts << recent.map { |m| "- #{m.content}" }.join("\n")
    
    # 2. Memoria a largo plazo importante
    important = @      .where(magent.memories
emory_type: :long)
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
