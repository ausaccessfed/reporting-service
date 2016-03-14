require 'rails_helper'

RSpec.describe FederatedLoginEvent, type: :model do
  describe 'Parse Ticket String' do
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

    context 'validations' do
      it { is_expected.to validate_presence_of(:relying_party) }
      it { is_expected.to validate_presence_of(:asserting_party) }
      it { is_expected.to validate_presence_of(:timestamp) }
      it { is_expected.to validate_presence_of(:result) }
      it { is_expected.to validate_presence_of(:hashed_principal_name) }
    end

    context 'fields' do
      let(:record) { FederatedLoginEvent.first }

      it 'should have values from :ticket_string' do
        expect(record.relying_party)
          .to eq('https://sp.example.edu/shibboleth')

        expect(record.asserting_party)
          .to eq('https://idp.example.edu/idp/shibboleth')

        pn = '72d2cce1bcda092e028ebf2a37a6001dcd6b444181fa2981100d12589b061942'
        expect(record.hashed_principal_name).to eq(pn)

        expect(record.result).to eq('OK')
      end
    end
  end
end
