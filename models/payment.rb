# frozen_string_literal: true

require 'active_record'

class Payment < ActiveRecord::Base
  has_many :payment_attempts

  validates :subscription_id, :total_amount, :remaining_amount, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :remaining_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :subscription_id, uniqueness: true
end
