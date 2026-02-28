class FixMemoriesVectorType < ActiveRecord::Migration[8.0]
  def up
    # Cambiamos la columna a tipo vector(768) que es el tamaño de nomic-embed-text
    # Usamos execute para evitar problemas con el parser de Rails que daba el warning
    execute <<-SQL
      ALTER TABLE memories 
      ALTER COLUMN embedding TYPE vector(768) 
      USING embedding::vector(768);
    SQL
  end

  def down
    execute "ALTER TABLE memories ALTER COLUMN embedding TYPE text USING embedding::text;"
  end
end
