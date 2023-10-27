# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RapidConnectService, type: :model do
  context 'validations' do
    let(:factory) { :rapid_connect_service }

    subject { build(:rapid_connect_service) }

    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:service_type) }
    it { is_expected.to validate_uniqueness_of(:identifier) }

    it_behaves_like 'a federation object'
  end

  describe '::find_by_identifying_attribute' do
    let!(:service) { create(:rapid_connect_service) }

    it 'finds by entity id' do
      expect(described_class.find_by_identifying_attribute(service.identifier)).to eq(service)
    end

    it 'returns nil when not found' do
      expect(described_class.find_by_identifying_attribute('urn:nonexistent')).to be_nil
    end
  end
end
