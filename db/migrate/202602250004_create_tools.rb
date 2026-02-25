class CreateTools < ActiveRecord::Migration[7.2]
  def change
    create_table :tools, id: :uuid do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :enabled, default: true
      t.jsonb :allowed_roles, default: ['assistant']
      t.jsonb :schema, default: {}
      t.timestamps
    end

    add_index :tools, :name, unique: true
    add_index :tools, :enabled
  end
end
