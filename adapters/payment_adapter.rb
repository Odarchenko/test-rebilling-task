# frozen_string_literal: true

module Adapters
  class PaymentAdapter
    URL = '/paymentIntents/create API'

    SUCCESS = 'success'
    FAILED = 'failed'
    INSUFFICIENT_FUNDS = 'insufficient_funds'

    def self.process_charge(args)
      new(**args).call
    end

    def initialize(amount:, subscription_id:)
      @subscription_id = subscription_id
      @amount = amount
    end

    def call
      # Simulate the API call to /paymentIntents/create
      response_status = [FAILED, SUCCESS, INSUFFICIENT_FUNDS].sample # just to imitiate adapter work

      { status: response_status }
    end

    private

    attr_reader :amount, :subscription_id
  end
end
