require 'rails_helper'

RSpec.describe FederatedLoginEvent, type: :model do
  describe 'Parse Ticket String' do
    let(:ticket) do
      'F-TICKS/AAF/1.0'\
      '#a#TS=1457558279'\
      '#RP=https://sp.example.edu/shibboleth#a'\
      '#AP=https://idp.example.edu/idp/shibboleth#4'\
      '#PN=72d2cce1bcda092e028ebf2a37a6001dcd6b444181fa2981100d12589b061942'\
      '#RESULT=OK#'
    end

    subject { FederatedLoginEvent.new }

    context 'validations' do
      it { is_expected.to validate_presence_of(:relying_party) }
      it { is_expected.to validate_presence_of(:asserting_party) }
      it { is_expected.to validate_presence_of(:timestamp) }
      it { is_expected.to validate_presence_of(:result) }
      it { is_expected.to validate_presence_of(:hashed_principal_name) }
    end

    context 'fields' do
      before { subject.generate_record(ticket) }

      let(:record) { FederatedLoginEvent.first }

      it 'should find :relying_party in :ticket_string' do
        expect(record.relying_party)
          .to eq('https://sp.example.edu/shibboleth')
      end

      it 'should find :asserting_party in :ticket_string' do
        expect(record.asserting_party)
          .to eq('https://idp.example.edu/idp/shibboleth')
      end

      it 'should find :hashed_principal_name in :ticket_string' do
        pn = '72d2cce1bcda092e028ebf2a37a6001dcd6b444181fa2981100d12589b061942'
        expect(record.hashed_principal_name).to eq(pn)
      end

      it 'should find and convert :timestamp in :ticket_string' do
        ts = 'Wed, 09 Mar 2016 21:17:59 UTC +00:00'
        expect(record.timestamp).to eq(ts)
      end

      it 'should find :result in :ticket_string' do
        expect(record.result).to eq('OK')
      end
    end

    context ':generate_record' do
      it 'when #RP is missing it should fail with message' do
        str = ticket.remove '#RP'
        msg = /Relying party can't be blank/

        expect { subject.generate_record(str) }
          .to raise_error(ActiveRecord::RecordInvalid, msg)
      end

      it 'when #AP is missing it should fail with message' do
        str = ticket.remove '#AP'
        msg = /Asserting party can't be blank/

        expect { subject.generate_record(str) }
          .to raise_error(ActiveRecord::RecordInvalid, msg)
      end

      it 'when #RESULT is missing it should fail with message' do
        str = ticket.remove '#RESULT'
        msg = /Result can't be blank/

        expect { subject.generate_record(str) }
          .to raise_error(ActiveRecord::RecordInvalid, msg)
      end

      it 'when #TS is missing it should fail with message' do
        msg = /Timestamp can't be blank/

        str = ticket.gsub '#TS=1457558279', '#TS=1457ddd'
        expect { subject.generate_record(str) }
          .to raise_error(ActiveRecord::RecordInvalid, msg)

        str = ticket.remove '#TS'
        expect { subject.generate_record(str) }
          .to raise_error(ActiveRecord::RecordInvalid, msg)
      end
    end
  end
end
