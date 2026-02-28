class Memory < ApplicationRecord
  belongs_to :agent
  belongs_to :session, optional: true

  validates :content, presence: true
  validates :memory_type, presence: true

  # Comentamos temporalmente hasta que el inicializador de pgvector esté listo
  # has_neighbors :embedding

  after_create_commit :generate_embedding_async

  enum :memory_type, {
    short: 'short',      # Corto plazo (última conversación)
    long: 'long',        # Largo plazo (hechos permanentes)
    semantic: 'semantic', # Conocimiento general
    episodic: 'episodic'  # Experiencias específicas
  }, prefix: :type

  # Búsqueda semántica por cercanía vectorial
  def self.search_semantic(query, limit: 5)
    vector = OllamaService.embed(query)
    return none unless vector
    
    nearest_neighbors(:embedding, vector, distance: "cosine").limit(limit)
  end

  # Generar embedding para esta memoria
  def generate_embedding!
    return unless content.present?
    
    vector = OllamaService.embed(content)
    if vector
      update_column(:embedding, vector)
    end
  end

  private

  def generate_embedding_async
    # Por ahora síncrono para MVP, luego Sidekiq
    generate_embedding!
  end
end
