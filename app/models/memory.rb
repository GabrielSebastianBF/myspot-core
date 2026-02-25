class Memory < ApplicationRecord
  belongs_to :agent
  belongs_to :session, optional: true

  validates :content, presence: true
  validates :memory_type, presence: true

  enum :memory_type, {
    short: 'short',      # Corto plazo (última conversación)
    long: 'long',        # Largo plazo (hechos permanentes)
    semantic: 'semantic', # Conocimiento general
    episodic: 'episodic'  # Experiencias específicas
  }, prefix: :type

  def importance_label
    case importance
    when 1 then 'low'
    when 2 then 'medium'
    when 3 then 'high'
    when 4 then 'critical'
    else 'unknown'
    end
  end
end
