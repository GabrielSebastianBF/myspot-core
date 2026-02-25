class CreateMemories < ActiveRecord::Migration[8.0]
  def change
    create_table :memories, id: :uuid do |t|
      t.references :agent, type: :uuid, null: false, foreign_key: true
      t.references :session, type: :uuid, foreign_key: true
      t.text :content, null: false
      t.string :memory_type, default: 'short'
      t.integer :importance, default: 1
      t.jsonb :tags, default: []
      t.column :embedding, 'vector(1536)'  # Nullable - solo se usa si hay API de embeddings
      t.timestamps
    end

    add_index :memories, :agent_id
    add_index :memories, :memory_type
    add_index :memories, :importance
    add_index :memories, :content, using: :gin, opclass: :gin_trgm_ops  # Búsqueda full-text
  end
end
