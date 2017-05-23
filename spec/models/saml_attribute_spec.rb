# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SAMLAttribute, type: :model do
  context 'validations' do
    subject { build(:saml_attribute) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe '::find_by_identifying_attribute' do
    let!(:attr) { create(:saml_attribute) }

    it 'finds by entity id' do
      expect(described_class.find_by_identifying_attribute(attr.name))
        .to eq(attr)
    end

    it 'returns nil when not found' do
      expect(described_class.find_by_identifying_attribute('urn:nonexistent'))
        .to be_nil
    end
  end
end
