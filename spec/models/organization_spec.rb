require 'rails_helper'

RSpec.describe Organization, type: :model do
  context 'validations' do
    let(:factory) { :organization }

    subject { build(:organization) }

    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:identifier) }

    it 'only permits the urlsafe base64 alphabet for `identifier`' do
      expect(subject).to allow_value('abcdefg').for(:identifier)
      expect(subject).to allow_value('abcdefg-_').for(:identifier)
      expect(subject).not_to allow_value('abcdefg-@').for(:identifier)
    end

    it_behaves_like 'a federation object'
  end
end
