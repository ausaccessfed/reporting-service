# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FederationReportsController, type: :routing do
  describe 'GET /federation_reports/federation_growth_report' do
    subject { { get: '/federation_reports/federation_growth_report' } }

    path = 'federation_reports#federation_growth_report'
    it { is_expected.to route_to(path) }
  end

  describe 'GET /federation_reports/federated_sessions_report' do
    subject { { get: '/federation_reports/federated_sessions_report' } }

    path = 'federation_reports#federated_sessions_report'
    it { is_expected.to route_to(path) }
  end

  describe 'GET /federation_reports/daily_demand_report' do
    subject { { get: '/federation_reports/daily_demand_report' } }

    path = 'federation_reports#daily_demand_report'
    it { is_expected.to route_to(path) }
  end
end
