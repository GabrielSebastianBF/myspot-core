# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 202602260001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "vector"

  create_table "agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "config", default: {}
    t.string "model_preferred"
    t.string "role", default: "assistant"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_agents_on_name"
    t.index ["role"], name: "index_agents_on_role"
  end

# Could not dump table "memories" because of following StandardError
#   Unknown type 'vector(768)' for column 'embedding'


  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "session_id", null: false
    t.string "role", limit: 255, null: false
    t.text "content", null: false
    t.datetime "created_at", default: -> { "now()" }
    t.datetime "updated_at", default: -> { "now()" }
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_id", null: false
    t.string "channel", default: "telegram"
    t.jsonb "metadata", default: {}
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_sessions_on_agent_id"
    t.index ["channel"], name: "index_sessions_on_channel"
  end

  create_table "tool_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "session_id"
    t.string "tool_name", null: false
    t.jsonb "args", default: {}
    t.jsonb "result", default: {}
    t.uuid "approved_by"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_tool_executions_on_session_id"
    t.index ["status"], name: "index_tool_executions_on_status"
    t.index ["tool_name"], name: "index_tool_executions_on_tool_name"
  end

  create_table "tools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "enabled", default: true
    t.jsonb "allowed_roles", default: ["assistant"]
    t.jsonb "schema", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_tools_on_enabled"
    t.index ["name"], name: "index_tools_on_name", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", limit: 255, null: false
    t.string "password_digest", limit: 255
    t.string "name", limit: 255
    t.string "role", limit: 255, default: "user"
    t.boolean "active", default: true
    t.datetime "created_at", default: -> { "now()" }
    t.datetime "updated_at", default: -> { "now()" }
    t.string "password", limit: 255
    t.index ["email"], name: "index_users_on_email", unique: true
    t.unique_constraint ["email"], name: "users_email_key"
  end

  add_foreign_key "memories", "agents"
  add_foreign_key "memories", "sessions"
  add_foreign_key "messages", "sessions", name: "messages_session_id_fkey"
  add_foreign_key "sessions", "agents"
  add_foreign_key "tool_executions", "sessions"
end
