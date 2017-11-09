# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171109213938) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "leaves", force: :cascade do |t|
    t.string   "mode",                   limit: 255, default: "original"
    t.boolean  "single",                             default: false
    t.integer  "quire_id"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "folio_number",           limit: 255
    t.boolean  "quire_uncertain",                    default: false
    t.integer  "folio_number_certainty",             default: 1
    t.integer  "mode_certainty",                     default: 1
  end

  add_index "leaves", ["quire_id"], name: "index_leaves_on_quire_id", using: :btree

  create_table "manuscripts", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "shelfmark",  limit: 255
    t.string   "url",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "quire_leaves", force: :cascade do |t|
    t.integer  "quire_id"
    t.integer  "leaf_id"
    t.integer  "position"
    t.integer  "certainty",         default: 1
    t.integer  "conjoin_certainty", default: 1
    t.integer  "subquire",          default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "quire_leaves", ["leaf_id"], name: "index_quire_leaves_on_leaf_id", using: :btree
  add_index "quire_leaves", ["quire_id"], name: "index_quire_leaves_on_quire_id", using: :btree

  create_table "quires", force: :cascade do |t|
    t.integer  "position"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "manuscript_id"
  end

  add_index "quires", ["manuscript_id"], name: "index_quires_on_manuscript_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "leaves", "quires"
  add_foreign_key "quire_leaves", "leaves"
  add_foreign_key "quire_leaves", "quires"
  add_foreign_key "quires", "manuscripts"
end
