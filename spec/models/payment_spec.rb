# frozen_string_literal: true

# spec/payment_spec.rb
require 'spec_helper'
require_relative '../../models/payment'
require_relative '../../models/payment_attempt'

RSpec.describe Payment, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:subscription_id) }
    it { is_expected.to validate_presence_of(:total_amount) }
    it { is_expected.to validate_presence_of(:remaining_amount) }

    it { is_expected.to validate_numericality_of(:total_amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:remaining_amount).is_greater_than_or_equal_to(0) }
  end

  describe 'relation' do
    it { is_expected.to have_many(:payment_attempts) }
  end
end
