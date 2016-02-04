require 'rails_helper'

RSpec.describe ServiceProviderSourceIdentityProvidersReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'service-provider-source-identity-providers' }
  let(:header) { [['IdP Name', 'Total']] }
  let(:title) { 'SP Source Identity Providers Report for' }

  let(:start) { 11.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:sp) { create :service_provider }
  let(:idp_01) { create :identity_provider }
  let(:idp_02) { create :identity_provider }
  let(:idp_03) { create :identity_provider }

  subject do
    ServiceProviderSourceIdentityProvidersReport
      .new(sp.entity_id, start, finish)
  end

  let(:report) { subject.generate }

  context 'SP Source IdPs Report' do
    it 'output should include :type, :title, :header and :footer' do
      output_title = "#{title} #{sp.name}"
      expect(report).to include(type: type,
                                title: output_title, header: header)
    end
  end

  context '#generate' do
    before do
      create_list :discovery_service_event, 20, :response,
                  initiating_sp: sp.entity_id,
                  selected_idp: idp_01.entity_id

      create_list :discovery_service_event, 5, :response,
                  initiating_sp: sp.entity_id,
                  selected_idp: idp_02.entity_id

      create_list :discovery_service_event, 10,
                  initiating_sp: sp.entity_id,
                  selected_idp: idp_03.entity_id,
                  timestamp: 20.days.ago.beginning_of_day
    end

    it 'creates report :rows with number of related IdPs and IdP names' do
      idp_name_01 = idp_01.name
      idp_name_02 = idp_02.name

      expect(report[:rows]).to include([idp_name_01, '20'])
      expect(report[:rows]).to include([idp_name_02, '5'])
    end

    it 'report should not include sessions out of range' do
      idp_name_03 = idp_03.name
      expect(report[:rows]).not_to include([idp_name_03, anything])
    end
  end
end
