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

ActiveRecord::Schema.define(version: 20160304150162) do

  create_table "id_maps", force: :cascade do |t|
    t.string   "connec_id",             limit: 255
    t.string   "connec_entity",         limit: 255
    t.string   "external_id",           limit: 255
    t.string   "external_entity",       limit: 255
    t.integer  "organization_id"
    t.datetime "last_push_to_connec"
    t.datetime "last_push_to_external"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "to_connec",                         default: true
    t.boolean  "to_external",                       default: true
    t.string   "name",                  limit: 255
    t.string   "message",               limit: 255
  end

  add_index "id_maps", ["connec_id", "connec_entity", "organization_id"], name: "idmap_connec_index"
  add_index "id_maps", ["external_id", "external_entity", "organization_id"], name: "idmap_external_index"
  add_index "id_maps", ["organization_id"], name: "idmap_organization_index"

  create_table "organizations", force: :cascade do |t|
    t.string   "provider",              limit: 255
    t.string   "uid",                   limit: 255
    t.string   "name",                  limit: 255
    t.string   "tenant",                limit: 255
    t.string   "oauth_provider",        limit: 255
    t.string   "oauth_uid",             limit: 255
    t.string   "oauth_name",            limit: 255
    t.string   "oauth_token",           limit: 255
    t.string   "refresh_token",         limit: 255
    t.string   "instance_url",          limit: 255
    t.string   "synchronized_entities", limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "sync_enabled",                      default: false
  end

  add_index "organizations", ["uid", "tenant"], name: "orga_uid_index"

  create_table "synchronizations", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "status",          limit: 255
    t.text     "message"
    t.boolean  "partial",                     default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "synchronizations", ["organization_id"], name: "synchronization_orga_id_index"

  create_table "user_organization_rels", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_organization_rels", ["organization_id"], name: "rels_orga_index"
  add_index "user_organization_rels", ["user_id"], name: "rels_user_index"

  create_table "users", force: :cascade do |t|
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "email",      limit: 255
    t.string   "locale",     limit: 255
    t.string   "timezone",   limit: 255
    t.string   "tenant",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "users", ["uid", "tenant"], name: "user_uid_index"

end
