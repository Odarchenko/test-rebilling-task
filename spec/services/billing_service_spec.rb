# frozen_string_literal: true

# spec/payment_spec.rb
require 'spec_helper'
require_relative '../../services/billing_service'
require_relative '../../models/payment'
require 'date'

RSpec.describe BillingService do
  subject(:result) { described_class.process_payment(payment: payment) }

  let(:payment) { Payment.create(total_amount: 100, remaining_amount: 100, subscription_id: 'test-id') }

  describe '#call' do
    context 'when possible to charge full amount' do
      let(:created_payment_attempt) { PaymentAttempt.last }

      before do
        allow(Adapters::PaymentAdapter)
          .to receive(:process_charge)
          .and_return({ status: Adapters::PaymentAdapter::SUCCESS })
      end

      it 'updates payment record' do
        result

        expect(payment.reload).to have_attributes(remaining_amount: 0, retry_at: nil)
      end

      it 'creates one payment attempt' do
        expect { result }.to change(PaymentAttempt, :count).by(1)
      end

      it 'creates payment attempts with proper data' do
        result

        expect(created_payment_attempt).to have_attributes(amount: 100, payment: payment,
                                                           status: PaymentAttempt::SUCCESS)
      end
    end

    context 'when failed response' do
      let(:created_payment_attempt) { PaymentAttempt.last }

      before do
        allow(Adapters::PaymentAdapter)
          .to receive(:process_charge)
          .and_return({ status: Adapters::PaymentAdapter::FAILED })
      end

      it 'updates payment record' do
        result

        expect(payment.reload).to have_attributes(remaining_amount: 100, retry_at: nil)
      end

      it 'creates one payment attempt' do
        expect { result }.to change(PaymentAttempt, :count).by(1)
      end

      it 'creates payment attempts with proper data' do
        result

        expect(created_payment_attempt).to have_attributes(amount: 100, payment: payment,
                                                           status: PaymentAttempt::FAILED)
      end
    end

    context 'when insufficient_funds response but success at 50%' do
      before do
        allow(Adapters::PaymentAdapter)
          .to receive(:process_charge)
          .with(subscription_id: payment.subscription_id, amount: 100)
          .and_return({ status: Adapters::PaymentAdapter::INSUFFICIENT_FUNDS })

        allow(Adapters::PaymentAdapter)
          .to receive(:process_charge)
          .with(subscription_id: payment.subscription_id, amount: 75)
          .and_return({ status: Adapters::PaymentAdapter::INSUFFICIENT_FUNDS })

        allow(Adapters::PaymentAdapter)
          .to receive(:process_charge)
          .with(subscription_id: payment.subscription_id, amount: 50)
          .and_return({ status: Adapters::PaymentAdapter::SUCCESS })
      end

      it 'updates payment record' do
        result

        expect(payment.reload).to have_attributes(remaining_amount: 50, retry_at: Date.today + 7)
      end

      it 'creates three payment attempt' do
        expect { result }.to change(PaymentAttempt, :count).by(3)
      end

      it 'creates three payment_attempts with proper attributes' do
        result

        expect(payment.payment_attempts.first).to have_attributes(
          amount: 100,
          status: PaymentAttempt::INSUFFICIENT_FUNDS
        )
        expect(payment.payment_attempts.second).to have_attributes(
          amount: 75,
          status: PaymentAttempt::INSUFFICIENT_FUNDS
        )
        expect(payment.payment_attempts.third).to have_attributes(
          amount: 50,
          status: PaymentAttempt::SUCCESS
        )
      end
    end

    context 'when insufficient_funds every time' do
      before do
        allow(Adapters::PaymentAdapter)
          .to receive(:process_charge)
          .and_return({ status: Adapters::PaymentAdapter::INSUFFICIENT_FUNDS })
      end

      it 'updates payment record' do
        result

        expect(payment.reload).to have_attributes(remaining_amount: 100, retry_at: nil)
      end

      it 'creates three payment attempt' do
        expect { result }.to change(PaymentAttempt, :count).by(4)
      end

      it 'creates four payment_attempts with proper attributes' do
        result

        expect(payment.payment_attempts.first).to have_attributes(
          amount: 100,
          status: PaymentAttempt::INSUFFICIENT_FUNDS
        )
        expect(payment.payment_attempts.second).to have_attributes(
          amount: 75,
          status: PaymentAttempt::INSUFFICIENT_FUNDS
        )
        expect(payment.payment_attempts.third).to have_attributes(
          amount: 50,
          status: PaymentAttempt::INSUFFICIENT_FUNDS
        )
        expect(payment.payment_attempts.last).to have_attributes(
          amount: 25,
          status: PaymentAttempt::INSUFFICIENT_FUNDS
        )
      end
    end
  end
end
