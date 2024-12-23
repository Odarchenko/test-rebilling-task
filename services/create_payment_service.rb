# frozen_string_literal: true

require_relative '../config/database'
require_relative '../models/payment'
require_relative '../services/billing_service'

class CreatePaymentService
  def self.create_payment(args)
    new(**args).call
  end

  def initialize(subscription_id:, amount:)
    @subscription_id = subscription_id
    @amount = amount
  end

  def call
    payment = create_payment!

    BillingService.process_payment(payment: payment)
  end

  private

  attr_reader :subscription_id, :amount

  def create_payment!
    Payment.create!(total_amount: amount, subscription_id: subscription_id, remaining_amount: amount)
  end
end
