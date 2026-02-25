class CreateAgents < ActiveRecord::Migration[7.2]
  def change
    create_table :agents, id: :uuid do |t|
      t.string :name, null: false
      t.jsonb :config, default: {}
      t.string :model_preferred
      t.string :role, default: 'assistant'
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :agents, :name
    add_index :agents, :role
  end
end
