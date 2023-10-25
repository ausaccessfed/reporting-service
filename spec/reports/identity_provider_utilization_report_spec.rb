# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentityProviderUtilizationReport do
  let(:type) { 'identity-provider-utilization' }
  let(:header) { [%w[Name Sessions]] }
  let(:title) { 'Identity Provider Utilization Report' }
  let(:output_title) { "#{title} (#{source_name})" }

  subject { IdentityProviderUtilizationReport.new(start, finish, source) }

  shared_examples 'Identity Provider Utilization report #Generate' do
    let(:object_type) { :identity_provider }

    it_behaves_like 'Utilization Report'
  end

  context 'IdentityProviderUtilizationReport with DS sessions' do
    let(:target) { :selected_idp }
    def create_event(timestamp, eid)
      create :discovery_service_event, :response, target => eid, :timestamp =>
    end

    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

    it_behaves_like 'Identity Provider Utilization report #Generate'
  end

  context 'IdentityProviderUtilizationReport with IdP sessions' do
    let(:target) { :asserting_party }
    def create_event(timestamp, eid)
      create :federated_login_event, :OK, target => eid, :timestamp =>
    end

    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

    it_behaves_like 'Identity Provider Utilization report #Generate'
  end
end
