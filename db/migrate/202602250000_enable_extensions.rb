class EnableExtensions < ActiveRecord::Migration[8.0]
  def change
    # Para búsqueda full-text cuando no hay embeddings
    enable_extension 'pg_trgm'
    
    # Para embeddings vectoriales (opcional)
    enable_extension 'vector'
  end
end
