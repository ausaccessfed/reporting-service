require 'rails_helper'

RSpec.describe IdentityProviderDestinationServicesReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'identity-provider-destination-services' }
  let(:header) { [['SP Name', 'Total']] }
  let(:title) { 'IdP Destination Report for' }

  let(:start) { 11.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:idp) { create :identity_provider }
  let(:sp_01) { create :service_provider }
  let(:sp_02) { create :service_provider }
  let(:sp_03) { create :service_provider }

  subject do
    IdentityProviderDestinationServicesReport.new(idp.entity_id, start, finish)
  end

  let(:report) { subject.generate }

  context 'IdP Destination Report' do
    it 'output should include :type, :title, :header and :footer' do
      output_title = "#{title} #{idp.name}"
      expect(report).to include(type: type,
                                title: output_title, header: header)
    end
  end

  context '#generate' do
    before do
      create_list :discovery_service_event, 20, :response,
                  identity_provider: idp,
                  service_provider: sp_01

      create_list :discovery_service_event, 5, :response,
                  identity_provider: idp,
                  service_provider: sp_02

      create_list :discovery_service_event, 10,
                  identity_provider: idp,
                  service_provider: sp_03,
                  timestamp: 20.day.ago.beginning_of_day
    end

    it 'creates report :rows with number of related SPs and SP names' do
      sp_name_01 = sp_01.name
      sp_name_02 = sp_02.name

      expect(report[:rows]).to include([sp_name_01, '20'])
      expect(report[:rows]).to include([sp_name_02, '5'])
    end

    it 'report should not include sessions out of range' do
      sp_name_03 = sp_03.name
      expect(report[:rows]).not_to include([sp_name_03, anything])
    end
  end
end
