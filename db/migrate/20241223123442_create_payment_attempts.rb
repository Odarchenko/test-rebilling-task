# frozen_string_literal: true

class CreatePaymentAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_attempts do |t|
      t.references :payment, null: false, foreign_key: true
      t.integer :amount, default: 0, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
