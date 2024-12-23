# frozen_string_literal: true

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

ActiveRecord::Schema[8.0].define(version: 20_241_223_123_442) do
  create_table 'payment_attempts', force: :cascade do |t|
    t.integer 'payment_id', null: false
    t.integer 'amount', default: 0, null: false
    t.string 'status', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['payment_id'], name: 'index_payment_attempts_on_payment_id'
  end

  create_table 'payments', force: :cascade do |t|
    t.string 'subscription_id', null: false
    t.integer 'total_amount', default: 0, null: false
    t.integer 'remaining_amount', default: 0, null: false
    t.date 'retry_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['subscription_id'], name: 'index_payments_on_subscription_id'
  end

  add_foreign_key 'payment_attempts', 'payments'
end
