# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServiceProvider, type: :model do
  context 'validations' do
    let(:factory) { :service_provider }

    subject { build(:service_provider) }

    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:name) }

    it_behaves_like 'a federation object'
  end

  describe '::find_by_identifying_attribute' do
    let!(:sp) { create(:service_provider) }

    it 'finds by entity id' do
      expect(described_class.find_by_identifying_attribute(sp.entity_id))
        .to eq(sp)
    end

    it 'returns nil when not found' do
      expect(described_class.find_by_identifying_attribute('urn:nonexistent'))
        .to be_nil
    end
  end
end
