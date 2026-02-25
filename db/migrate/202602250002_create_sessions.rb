class CreateSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :sessions, id: :uuid do |t|
      t.references :agent, type: :uuid, null: false, foreign_key: true
      t.string :channel, default: 'telegram'
      t.jsonb :metadata, default: {}
      t.datetime :started_at
      t.datetime :ended_at
      t.timestamps
    end

    add_index :sessions, :agent_id
    add_index :sessions, :channel
  end
end
