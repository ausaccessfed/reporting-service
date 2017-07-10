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
                                                  source)
  end

  let(:report) { subject.generate }

  shared_examples 'IdP Destination Report' do
    it 'output should include :type, :title, :header and :footer' do
      output_title = "#{title} #{idp.name} (#{source_name})"
      expect(report).to include(type: type,
                                title: output_title, header: header)
    end
  end

  shared_examples '#generate' do
    before do
      20.times { create_event(idp.entity_id) }
      20.times { create_event(idp.entity_id, sp1.entity_id) }
      5.times { create_event(idp.entity_id, sp2.entity_id) }
      long_ago = 20.days.ago.beginning_of_day
      10.times { create_event(idp.entity_id, sp3.entity_id, long_ago) }
      5.times { create_event(idp2.entity_id, sp4.entity_id) }
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

  context 'when sessions are Discovery Service sessions' do
    def create_event(idp_entity_id, sp_entity_id = nil, timestamp = nil)
      create :discovery_service_event, :response,
             { selected_idp: idp_entity_id,
               initiating_sp: sp_entity_id,
               timestamp: timestamp }.compact
    end

    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

    it_behaves_like 'IdP Destination Report'
    it_behaves_like '#generate'
  end

  context 'when events are IdP sessions' do
    def create_event(idp_entity_id, sp_entity_id = nil, timestamp = nil)
      create :federated_login_event, :OK,
             { asserting_party: idp_entity_id,
               relying_party: sp_entity_id,
               timestamp: timestamp }.compact
    end

    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

    it_behaves_like 'IdP Destination Report'
    it_behaves_like '#generate'
  end
end
