# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceProviderSourceIdentityProvidersReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'service-provider-source-identity-providers' }
  let(:header) { [['IdP Name', 'Total']] }
  let(:title) { 'SP Source Identity Providers Report for' }

  let(:start) { 11.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:sp) { create :service_provider }
  let(:sp2) { create :service_provider }
  let(:idp1) { create :identity_provider }
  let(:idp2) { create :identity_provider }
  let(:idp3) { create :identity_provider }
  let(:idp4) { create :identity_provider }

  subject do
    ServiceProviderSourceIdentityProvidersReport
      .new(sp.entity_id, start, finish, 'DS')
  end

  let(:report) { subject.generate }

  context 'SP Source IdPs Report' do
    it 'output should include :type, :title, :header and :footer' do
      output_title = "#{title} #{sp.name} (Discovery Service)"
      expect(report).to include(type: type,
                                title: output_title, header: header)
    end
  end

  context '#generate' do
    before do
      create_list :discovery_service_event, 20, :response,
                  initiating_sp: sp.entity_id

      create_list :discovery_service_event, 20, :response,
                  initiating_sp: sp.entity_id,
                  selected_idp: idp1.entity_id

      create_list :discovery_service_event, 5, :response,
                  initiating_sp: sp.entity_id,
                  selected_idp: idp2.entity_id

      create_list :discovery_service_event, 10,
                  initiating_sp: sp.entity_id,
                  selected_idp: idp3.entity_id,
                  timestamp: 20.days.ago.beginning_of_day

      create_list :discovery_service_event, 5, :response,
                  initiating_sp: sp2.entity_id,
                  selected_idp: idp4.entity_id
    end

    it 'creates report :rows with number of related IdPs and IdP names
        only with existing entities' do
      expect(report[:rows]).to include([idp1.name, '20'])
      expect(report[:rows]).to include([idp2.name, '5'])
    end

    it 'report should not include sessions out of range' do
      expect(report[:rows]).not_to include([idp3.name, anything])
    end

    it 'report should not include sessions from irrelevant entities' do
      expect(report[:rows]).not_to include([idp4.name, anything])
    end
  end
end
