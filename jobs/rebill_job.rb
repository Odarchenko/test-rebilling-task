# frozen_string_literal: true

require 'sidekiq'
require_relative '../config/database'
require_relative '../models/payment'
require_relative '../services/billing_service'

class RebillJob
  include Sidekiq::Worker

  def perform(payment_id)
    payment = Payment.find_by(id: payment_id)

    BillingService.process_payment(payment: payment)
  end
end
