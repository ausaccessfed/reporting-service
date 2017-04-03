# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activation, type: :model do
  context 'validations' do
    subject { build(:activation) }

    it { is_expected.to validate_presence_of(:federation_object) }
    it { is_expected.to validate_presence_of(:activated_at) }
    it { is_expected.not_to validate_presence_of(:deactivated_at) }
  end
end
