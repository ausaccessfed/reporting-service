require 'rails_helper'

RSpec.describe FederationReportsController, type: :routing do
  describe 'GET /federation_reports/federation_growth' do
    subject { { get: '/federation_reports/federation_growth' } }
    it { is_expected.to route_to('federation_reports#federation_growth') }
  end

  describe 'GET /federation_reports/federated_sessions' do
    subject { { get: '/federation_reports/federated_sessions' } }
    it { is_expected.to route_to('federation_reports#federated_sessions') }
  end

  describe 'GET /federation_reports/daily_demand' do
    subject { { get: '/federation_reports/daily_demand' } }
    it { is_expected.to route_to('federation_reports#daily_demand') }
  end
end
