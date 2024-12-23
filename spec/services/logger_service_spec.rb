# frozen_string_literal: true

# spec/payment_spec.rb
require 'spec_helper'
require_relative '../../services/logger_service'
require_relative '../../models/payment'
require_relative '../../models/payment_attempt'

RSpec.describe LoggerService do
  subject(:result) { described_class.find_logs(subscription_id: subscription_id) }

  describe '#find_logs' do
    context 'when subscription_id correct' do
      let(:subscription_id) { payment.subscription_id }

      let!(:payment) do
        Payment.create(total_amount: 100, remaining_amount: 50, retry_at: Date.today, subscription_id: 'test')
      end

      let!(:payment_attempt) { PaymentAttempt.create(amount: 50, status: PaymentAttempt::SUCCESS, payment: payment) }

      it 'returns structured log' do
        expect(result).to eq({
                               subscription_id: subscription_id,
                               retry_at: payment.retry_at,
                               total_amount: payment.total_amount,
                               remaining_amount: payment.remaining_amount,
                               created_at: payment.created_at,
                               payment_attempts: [{
                                 status: payment_attempt.status,
                                 charge_amount: payment_attempt.amount,
                                 created_at: payment_attempt.created_at
                               }]
                             })
      end
    end

    context 'when invalid subscribe_id' do
      let(:subscription_id) { 'invalid' }

      it 'raises an error' do
        expect { result }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
