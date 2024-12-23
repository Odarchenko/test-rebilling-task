# frozen_string_literal: true

# spec/payment_attempt_spec.rb
require 'spec_helper'
require_relative '../../models/payment'
require_relative '../../models/payment_attempt'

RSpec.describe PaymentAttempt, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:payment_id) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(PaymentAttempt::STATUSES) }
  end

  describe 'relations' do
    it { is_expected.to belong_to(:payment) }
  end
end
