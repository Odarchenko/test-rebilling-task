# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.string :subscription_id, null: false, index: true
      t.integer :total_amount, default: 0, null: false
      t.integer :remaining_amount, default: 0, null: false
      t.date    :retry_at

      t.timestamps
    end
  end
end
