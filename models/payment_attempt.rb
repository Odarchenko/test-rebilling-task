# frozen_string_literal: true

require 'active_record'

class PaymentAttempt < ActiveRecord::Base
  SUCCESS = 'success'
  FAILED = 'failed'
  INSUFFICIENT_FUNDS = 'insufficient_funds'

  STATUSES = [SUCCESS, FAILED, INSUFFICIENT_FUNDS].freeze

  belongs_to :payment

  validates :payment_id, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
end
