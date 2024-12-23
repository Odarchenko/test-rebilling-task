# frozen_string_literal: true

require_relative '../config/database'
require_relative '../models/payment'
require 'money'

class LoggerService
  def self.find_logs(args)
    new(**args).call
  end

  def initialize(subscription_id:)
    @subscription_id = subscription_id
  end

  def call
    {
      subscription_id: subscription_id,
      retry_at: payment.retry_at,
      total_amount: payment.total_amount,
      remaining_amount: payment.remaining_amount,
      created_at: payment.created_at,
      payment_attempts: payment_attempts
    }
  end

  private

  attr_reader :subscription_id

  def payment_attempts
    payment.payment_attempts.map do |payment_attempt|
      {
        status: payment_attempt.status,
        charge_amount: payment_attempt.amount,
        created_at: payment_attempt.created_at
      }
    end
  end

  def payment
    @payment ||= Payment.find_by!(subscription_id: subscription_id)
  end
end
