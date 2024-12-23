# frozen_string_literal: true

# spec/payment_spec.rb
require 'spec_helper'
require_relative '../../services/create_payment_service'
require_relative '../../services/billing_service'
require_relative '../../models/payment'

RSpec.describe CreatePaymentService do
  subject(:result) { described_class.create_payment(amount: amount, subscription_id: subscription_id) }

  let(:error_free_result) do
    result
  rescue StandardError # rubocop:disable Lint/SuppressedException
  end

  describe '#call' do
    context 'when valid data' do
      let(:amount)          { 200 }
      let(:subscription_id) { 'test-id' }
      let(:created_payment) { Payment.last }

      before do
        allow(Adapters::PaymentAdapter)
          .to receive(:process_charge)
          .and_return({ status: Adapters::PaymentAdapter::FAILED })
      end

      it 'creates payment' do
        expect { result }.to change(Payment, :count).by(1)
      end

      it 'creates payment with proper data' do
        result

        expect(created_payment).to have_attributes(
          total_amount: amount,
          subscription_id: subscription_id,
          remaining_amount: amount
        )
      end

      it 'starts billing process' do
        allow(BillingService).to receive(:process_payment).and_call_original

        result
        expect(BillingService).to have_received(:process_payment).with(payment: created_payment)
      end
    end

    context 'when invalid amount' do
      let(:amount)          { -100 }
      let(:subscription_id) { 'test-id' }

      it 'does not create payment' do
        expect { error_free_result }.not_to(change(Payment, :count))
      end

      it 'does not start billing process' do
        allow(BillingService).to receive(:process_payment).and_call_original
        error_free_result
        expect(BillingService).not_to have_received(:process_payment)
      end

      it 'raises an error' do
        expect do
          result
        end.to raise_error(ActiveRecord::RecordInvalid,
                           /Validation failed: Total amount must be greater than or equal to 0/)
      end
    end

    context 'when duplicate subscription_id' do
      let(:amount)          { 100 }
      let(:subscription_id) { 'test-id' }

      before { Payment.create(total_amount: 200, subscription_id: subscription_id) }

      it 'does not create payment' do
        expect { error_free_result }.not_to(change(Payment, :count))
      end

      it 'does not start billing process' do
        allow(BillingService).to receive(:process_payment).and_call_original
        error_free_result
        expect(BillingService).not_to have_received(:process_payment)
      end

      it 'raises an error' do
        expect do
          result
        end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Subscription has already been taken/)
      end
    end
  end
end
