require 'rails_helper'

RSpec.describe IdentityProviderReportsController do
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

  describe 'get & post identity_provider/sessions_report' do
    let(:action) { 'identity_provider_reports#sessions_report' }
    let(:path) { '/identity_provider/sessions_report' }

    it_behaves_like 'get request'
    it_behaves_like 'post request'
  end

  describe 'get & post identity_provider/daily_demand_report' do
    let(:action) { 'identity_provider_reports#daily_demand_report' }
    let(:path) { '/identity_provider/daily_demand_report' }

    it_behaves_like 'get request'
    it_behaves_like 'post request'
  end

  describe 'get & post identity_provider/destination_services_report' do
    let(:action) { 'identity_provider_reports#destination_services_report' }
    let(:path) { '/identity_provider/destination_services_report' }

    it_behaves_like 'get request'
    it_behaves_like 'post request'
  end
end
