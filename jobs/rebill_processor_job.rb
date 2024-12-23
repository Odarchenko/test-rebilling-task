# frozen_string_literal: true

require 'sidekiq'
require_relative '../config/database'
require_relative '../jobs/rebill_job'
require_relative '../models/payment'

class RebillProcessorJob
  include Sidekiq::Worker

  def perform
    payments = Payment.where(retry_at: Date.today).where.not(remaining_amount: 0)

    payments.find_each do |payment|
      RebillJob.perform_async(payment.id)
    end
  end
end
