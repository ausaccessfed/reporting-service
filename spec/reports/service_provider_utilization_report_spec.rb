# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceProviderUtilizationReport do
  subject { described_class.new(start, finish, source) }

  let(:type) { 'service-provider-utilization' }
  let(:header) { [%w[Name Sessions]] }
  let(:title) { 'Service Provider Utilization Report' }
  let(:output_title) { "#{title} (#{source_name})" }

  shared_examples 'Service Provider Utilization report #Generate' do
    let(:object_type) { :service_provider }

    it_behaves_like 'Utilization Report'
  end

  context 'ServiceProviderUtilizationReport with DS sessions' do
    let(:target) { :initiating_sp }
    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

    def create_event(timestamp, eid)
      create(:discovery_service_event, :response, target => eid, :timestamp => timestamp)
    end

    it_behaves_like 'Service Provider Utilization report #Generate'
  end

  context 'ServiceProviderUtilizationReport with IdP sessions' do
    let(:target) { :relying_party }
    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

    def create_event(timestamp, eid)
      create(:federated_login_event, :OK, target => eid, :timestamp => timestamp)
    end

    it_behaves_like 'Service Provider Utilization report #Generate'
  end
end
