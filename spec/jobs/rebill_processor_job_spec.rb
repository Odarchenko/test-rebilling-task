# frozen_string_literal: true

# spec/payment_attempt_spec.rb
require 'spec_helper'
require_relative '../../models/payment'
require_relative '../../jobs/rebill_processor_job'
require_relative '../../jobs/rebill_job'

RSpec.describe RebillProcessorJob, type: :job do
  subject(:result) { described_class.perform_sync }

  let!(:payment_a) do
    Payment.create(
      total_amount: 100,
      remaining_amount: 100,
      subscription_id: 'test-id',
      retry_at: Date.yesterday
    )
  end

  let!(:payment_b) do
    Payment.create(
      total_amount: 100,
      remaining_amount: 100,
      subscription_id: 'test-id-b',
      retry_at: Date.today
    )
  end

  let!(:payment_c) do
    Payment.create(
      total_amount: 100,
      remaining_amount: 0,
      subscription_id: 'test-id-b',
      retry_at: Date.today
    )
  end

  describe '#perform' do
    it 'schedule rebilling payment which have retry at today' do
      allow(RebillJob).to receive(:perform_async).and_return(true)
      result
      expect(RebillJob).to have_received(:perform_async).with(payment_b.id)
      expect(RebillJob).not_to have_received(:perform_async).with(payment_a.id)
      expect(RebillJob).not_to have_received(:perform_async).with(payment_c.id)
    end
  end
end
