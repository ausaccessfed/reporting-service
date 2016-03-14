require 'rails_helper'

RSpec.describe FederatedLoginEvent, type: :model do
  describe 'validations' do
    let(:ticket_string) do
      'F-TICKS/AAF/1.0'\
      '#TS=1457558279'\
      '#RP=https://sp.example.edu/shibboleth'\
      '#AP=https://idp.example.edu/idp/shibboleth'\
      '#PN=72d2cce1bcda092e028ebf2a37a6001dcd6b444181fa2981100d12589b061942'\
      '#RESULT=OK#'
    end

    subject { FederatedLoginEvent.new }

    before { subject.generate_record(ticket_string) }

    it { is_expected.to validate_presence_of(:relying_party) }
    it { is_expected.to validate_presence_of(:asserting_party) }
    it { is_expected.to validate_presence_of(:timestamp) }
    it { is_expected.to validate_presence_of(:result) }
    it { is_expected.to validate_presence_of(:hashed_principal_name) }

    it { is_expected.to validate_uniqueness_of(:hashed_principal_name) }
  end
end
