require 'rails_helper'

RSpec.describe ServiceProviderReportsController do
  shared_examples 'get request' do
    subject do
      { get: "/subscriber_reports#{path}" }
    end

    it { is_expected.to route_to(action) }
  end

  shared_examples 'post request' do
    subject do
      { post: "/subscriber_reports#{path}" }
    end

    it { is_expected.to route_to(action) }
  end

  describe 'get & post service_provider/sessions_report' do
    let(:action) { 'service_provider_reports#sessions_report' }
    let(:path) { '/service_provider/sessions_report' }

    it_behaves_like 'get request'
    it_behaves_like 'post request'
  end

  describe 'get & post service_provider/daily_demand_report' do
    let(:action) { 'service_provider_reports#daily_demand_report' }
    let(:path) { '/service_provider/daily_demand_report' }

    it_behaves_like 'get request'
    it_behaves_like 'post request'
  end

  describe 'get & post service_provider/source_identity_providers_report' do
    let(:action) do
      'service_provider_reports#source_identity_providers_report'
    end

    let(:path) { '/service_provider/source_identity_providers_report' }

    it_behaves_like 'get request'
    it_behaves_like 'post request'
  end
end
