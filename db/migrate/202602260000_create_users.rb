class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    # Si la tabla ya existe (creada manualmente o en migración fallida), solo agregamos las columnas faltantes
    if table_exists?(:users)
      change_table :users do |t|
        t.string :password_digest unless column_exists?(:users, :password_digest)
        t.string :name unless column_exists?(:users, :name)
        t.string :role, default: "user" unless column_exists?(:users, :role)
        t.boolean :active, default: true unless column_exists?(:users, :active)
        t.timestamps unless column_exists?(:users, :created_at)
      end
    else
      create_table :users, id: :uuid do |t|
        t.string :email, null: false
        t.string :password_digest, null: false
        t.string :name
        t.string :role, default: "user"
        t.boolean :active, default: true

        t.timestamps
      end
    end
    
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
  end
end
