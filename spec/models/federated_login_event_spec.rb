# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FederatedLoginEvent, type: :model do
  describe 'Parse data String' do
    let(:data) do
      'F-TICKS/AAF/1.0' \
        '#a#TS=1457558279' \
        '#RP=https://sp.example.edu/shibboleth#a' \
        '#AP=https://idp.example.edu/idp/shibboleth#4' \
        '#PN=72d2cce1bcda092e028ebf2a37a6001dcd6b444181fa2981100d12589b061942' \
        '#RESULT=OK#'
    end

    let!(:incoming_event) { create :incoming_f_ticks_event, data: }

    subject { FederatedLoginEvent.new }

    context 'validations' do
      it { is_expected.to validate_presence_of(:relying_party) }
      it { is_expected.to validate_presence_of(:asserting_party) }
      it { is_expected.to validate_presence_of(:timestamp) }
      it { is_expected.to validate_presence_of(:result) }
      it { is_expected.to validate_presence_of(:hashed_principal_name) }
    end

    context 'fields' do
      before { subject.create_instance(incoming_event) }

      let(:event) { FederatedLoginEvent.first }

      it 'should find :relying_party in :data_string' do
        expect(event.relying_party).to eq('https://sp.example.edu/shibboleth')
      end

      it 'should find :asserting_party in :data_string' do
        expect(event.asserting_party).to eq('https://idp.example.edu/idp/shibboleth')
      end

      it 'should find :hashed_principal_name in :data_string' do
        pn = '72d2cce1bcda092e028ebf2a37a6001dcd6b444181fa2981100d12589b061942'
        expect(event.hashed_principal_name).to eq(pn)
      end

      it 'should find and convert :timestamp in :data_string' do
        ts = 'Wed, 09 Mar 2016 21:17:59 UTC +00:00'
        expect(event.timestamp).to eq(ts)
      end

      it 'should find :result in :data_string' do
        expect(event.result).to eq('OK')
      end
    end

    context ':create_instance' do
      def run
        subject.create_instance incoming_event
      end

      %w[#RP #AP #RESULT #TS].each do |field|
        it 'should return false when data is invalid' do
          incoming_event.data.remove! field

          expect(run).to eq false
        end
      end

      it 'when #TS is missing it should fail with message' do
        incoming_event.data.gsub! '#TS=1457558279', '#TS=1457ddd'

        expect(run).to eq false
      end
    end
  end
end
