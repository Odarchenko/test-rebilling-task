# frozen_string_literal: true

require_relative '../models/payment'
require_relative '../models/payment_attempt'
require_relative '../adapters/payment_adapter'
require 'money'

class BillingService
  MULTIPLIERS = [1.0, 0.75, 0.5, 0.25].freeze

  def self.process_payment(args)
    new(**args).call
  end

  def initialize(payment:)
    @payment = payment
  end

  def call
    MULTIPLIERS.any? do |multiplier|
      amount = calculate_chargeable_amount(multiplier)
      result = Adapters::PaymentAdapter.process_charge(amount: amount, subscription_id: subscription_id)

      process_attempt(result, amount)

      [Adapters::PaymentAdapter::SUCCESS, Adapters::PaymentAdapter::FAILED].include?(result[:status])
    end
  end

  private

  attr_reader :payment

  delegate :remaining_amount, :subscription_id, to: :payment

  def process_attempt(result, amount)
    case result[:status]
    when Adapters::PaymentAdapter::SUCCESS
      process_success_payment(amount)
    when Adapters::PaymentAdapter::FAILED
      process_failed_payment(amount)
    when Adapters::PaymentAdapter::INSUFFICIENT_FUNDS
      process_insufficient_funds(amount)
    end
  end

  def process_success_payment(amount)
    payment.payment_attempts.create!(status: PaymentAttempt::SUCCESS, amount: amount)

    amount_left = remaining_amount - amount
    payment.update(remaining_amount: amount_left, retry_at: amount_left.zero? ? nil : Date.today + 7)
  end

  def process_failed_payment(amount)
    payment.payment_attempts.create!(status: PaymentAttempt::FAILED, amount: amount)
  end

  def process_insufficient_funds(amount)
    payment.payment_attempts.create!(status: PaymentAttempt::INSUFFICIENT_FUNDS, amount: amount)
  end

  def calculate_chargeable_amount(multiplier)
    (Money.new(remaining_amount) * multiplier).fractional
  end
end
