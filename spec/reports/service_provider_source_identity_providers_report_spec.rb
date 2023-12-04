# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceProviderSourceIdentityProvidersReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'service-provider-source-identity-providers' }
  let(:header) { [['IdP Name', 'Total']] }
  let(:title) { 'SP Source Identity Providers Report for' }

  let(:start) { 11.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:sp) { create(:service_provider) }
  let(:sp2) { create(:service_provider) }
  let(:idp1) { create(:identity_provider) }
  let(:idp2) { create(:identity_provider) }
  let(:idp3) { create(:identity_provider) }
  let(:idp4) { create(:identity_provider) }

  subject { ServiceProviderSourceIdentityProvidersReport.new(sp.entity_id, start, finish, source) }

  let(:report) { subject.generate }

  shared_examples 'SP Source IdPs Report' do
    it 'output should include :type, :title, :header and :footer' do
      output_title = "#{title} #{sp.name} (#{source_name})"
      expect(report).to include(type:, title: output_title, header:)
    end
  end

  shared_examples '#generate' do
    before do
      20.times { create_event(nil, sp.entity_id) }
      20.times { create_event(idp1.entity_id, sp.entity_id) }
      5.times { create_event(idp2.entity_id, sp.entity_id) }
      long_ago = 20.days.ago.beginning_of_day
      10.times { create_event(idp3.entity_id, sp.entity_id, long_ago) }
      5.times { create_event(idp4.entity_id, sp2.entity_id) }
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

  context 'when sessions are Discovery Service sessions' do
    def create_event(idp_entity_id, sp_entity_id = nil, timestamp = nil)
      create(
        :discovery_service_event,
        :response,
        { selected_idp: idp_entity_id, initiating_sp: sp_entity_id, timestamp: }.compact
      )
    end

    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

    it_behaves_like 'SP Source IdPs Report'
    it_behaves_like '#generate'
  end

  context 'when events are IdP sessions' do
    def create_event(idp_entity_id, sp_entity_id = nil, timestamp = nil)
      create(
        :federated_login_event,
        :OK,
        { asserting_party: idp_entity_id, relying_party: sp_entity_id, timestamp: }.compact
      )
    end

    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

    it_behaves_like 'SP Source IdPs Report'
    it_behaves_like '#generate'
  end
end
