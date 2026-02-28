class CreateToolExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :tool_executions, id: :uuid do |t|
      t.references :session, type: :uuid, foreign_key: true
      t.string :tool_name, null: false
      t.jsonb :args, default: {}
      t.jsonb :result, default: {}
      t.uuid :approved_by
      t.string :status, default: 'pending'
      t.timestamps
    end

    add_index :tool_executions, :tool_name
    add_index :tool_executions, :status
  end
end
