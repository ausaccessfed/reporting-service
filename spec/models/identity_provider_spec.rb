# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentityProvider do
  context 'validations' do
    subject { build(:identity_provider) }

    let(:factory) { :identity_provider }


    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:entity_id) }

    it_behaves_like 'a federation object'
  end

  describe '::find_by_identifying_attribute' do
    let!(:idp) { create(:identity_provider) }

    it 'finds by entity id' do
      expect(described_class.find_by_identifying_attribute(idp.entity_id)).to eq(idp)
    end

    it 'returns nil when not found' do
      expect(described_class.find_by_identifying_attribute('urn:nonexistent')).to be_nil
    end
  end
end
