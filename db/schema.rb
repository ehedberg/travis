# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080604155229) do

  create_table "iterations", :force => true do |t|
    t.string   "title",      :limit => 200, :null => false
    t.date     "start_date",                :null => false
    t.date     "end_date",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stories", :force => true do |t|
    t.string   "title",        :limit => 200, :null => false
    t.text     "description"
    t.decimal  "swag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iteration_id"
  end

  create_table "stories_tasks", :force => true do |t|
    t.decimal  "story_id",   :null => false
    t.decimal  "task_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "title",       :limit => 200, :null => false
    t.text     "description",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
