# frozen_string_literal: true

class MemoryService
  # Servicio para gestionar memorias
  # Usa Ollama local para embeddings (gratis, sin tokens)
  # Fallback: búsqueda full-text de PostgreSQL
  
  OLLAMA_URL = ENV.fetch('OLLAMA_URL', 'http://localhost:11434')
  OLLAMA_EMBED_MODEL = ENV.fetch('OLLAMA_EMBED_MODEL', 'nomic-embed-text')

  def initialize(agent:)
    @agent = agent
  end

  # Crear embedding usando Ollama local
  # Modelo: nomic-embed-text (768 dimensiones)
  def create_embedding(text)
    begin
      uri = URI.parse("#{OLLAMA_URL}/api/embeddings")
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = {
        model: OLLAMA_EMBED_MODEL,
        prompt: text
      }.to_json

      response = http.request(request)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        data['embedding']
      else
        Rails.logger.warn "Ollama embedding failed: #{response.code}"
        nil
      end
    rescue => e
      Rails.logger.warn "Ollama unavailable: #{e.message}"
      nil
    end
  end

  # Verificar si Ollama está disponible
  def ollama_available?
    begin
      uri = URI.parse("#{OLLAMA_URL}/api/tags")
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 2
      http.read_timeout = 2
      response = http.get(uri.path)
      response.code == '200'
    rescue
      false
    end
  end

  # Buscar memorias similares
  # Si hay embedding: búsqueda vectorial (pgvector)
  # Si no: búsqueda full-text con PostgreSQL
  def search_similar(query, limit: 5, memory_types: nil)
    memories = Memory.where(agent: @agent)
    memories = memories.where(memory_type: memory_types) if memory_types.present?

    # Intentar embedding con Ollama
    query_embedding = create_embedding(query)
    
    if query_embedding
      # Búsqueda vectorial (pgvector)
      emb_str = query_embedding.to_s.gsub('[', '(').gsub(']', ')')
      memories = memories.where.not(embedding: nil)
        .order("embedding <=> #{emb_str}")
    else
      # Fallback: búsqueda full-text
      search_term = "%#{query}%"
      memories = memories.where("content ILIKE ?", search_term)
    end

    memories.limit(limit)
  end

  # Agregar nueva memoria
  # Genera embedding automáticamente con Ollama
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
