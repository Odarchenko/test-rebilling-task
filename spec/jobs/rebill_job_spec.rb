# frozen_string_literal: true

# spec/payment_attempt_spec.rb
require 'spec_helper'
require_relative '../../models/payment'
require_relative '../../services/billing_service'
require_relative '../../jobs/rebill_job'

RSpec.describe RebillJob, type: :job do
  subject(:result) { described_class.perform_sync(payment.id) }

  let(:payment) { Payment.create(total_amount: 100, remaining_amount: 100, subscription_id: 'test-id') }

  describe '#perform' do
    it 'start billing service' do
      allow(BillingService).to receive(:process_payment).and_return(true)
      result
      expect(BillingService).to have_received(:process_payment).with(payment: payment)
    end
  end
end
