# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentityProviderDestinationServicesReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'identity-provider-destination-services' }
  let(:header) { [['SP Name', 'Total']] }
  let(:title) { 'IdP Destination Report for' }

  let(:start) { 11.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:idp) { create :identity_provider }
  let(:idp2) { create :identity_provider }
  let(:sp1) { create :service_provider }
  let(:sp2) { create :service_provider }
  let(:sp3) { create :service_provider }
  let(:sp4) { create :service_provider }

  subject do
    IdentityProviderDestinationServicesReport.new(idp.entity_id, start, finish,
                                                  'DS')
  end

  let(:report) { subject.generate }

  context 'IdP Destination Report' do
    it 'output should include :type, :title, :header and :footer' do
      output_title = "#{title} #{idp.name} (Discovery Service)"
      expect(report).to include(type: type,
                                title: output_title, header: header)
    end
  end

  context '#generate' do
    before do
      create_list :discovery_service_event, 20, :response,
                  selected_idp: idp.entity_id

      create_list :discovery_service_event, 20, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp1.entity_id

      create_list :discovery_service_event, 5, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp2.entity_id

      create_list :discovery_service_event, 10,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp3.entity_id,
                  timestamp: 20.days.ago.beginning_of_day

      create_list :discovery_service_event, 5, :response,
                  selected_idp: idp2.entity_id,
                  initiating_sp: sp4.entity_id
    end

    it 'creates report :rows with number of related SPs and SP names
        only with existing entities' do
      expect(report[:rows]).to include([sp1.name, '20'])
      expect(report[:rows]).to include([sp2.name, '5'])
    end

    it 'report should not include sessions out of range' do
      expect(report[:rows]).not_to include([sp3.name, anything])
    end

    it 'report should not include sessions from irrelevant entities' do
      expect(report[:rows]).not_to include([sp4.name, anything])
    end
  end
end
