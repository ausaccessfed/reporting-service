require 'rails_helper'

RSpec.describe Attribute, type: :model do
  context 'validations' do
    subject { build(:attribute) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
  end
end
