# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceProviderReportsController, type: :routing do
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

  describe 'get service_provider_sessions_report' do
    let(:action) { 'service_provider_reports#sessions_report' }
    let(:path) { '/service_provider_sessions_report' }

    it_behaves_like 'get request'
  end

  describe 'post service_provider_sessions_report' do
    let(:action) { 'service_provider_reports#sessions_report' }
    let(:path) { '/service_provider_sessions_report' }

    it_behaves_like 'post request'
  end

  describe 'get service_provider_daily_demand_report' do
    let(:action) { 'service_provider_reports#daily_demand_report' }
    let(:path) { '/service_provider_daily_demand_report' }

    it_behaves_like 'get request'
  end

  describe 'post service_provider_daily_demand_report' do
    let(:action) { 'service_provider_reports#daily_demand_report' }
    let(:path) { '/service_provider_daily_demand_report' }

    it_behaves_like 'post request'
  end

  describe 'get service_provider_source_identity_providers_report' do
    let(:action) do
      'service_provider_reports#source_identity_providers_report'
    end

    let(:path) { '/service_provider_source_identity_providers_report' }

    it_behaves_like 'get request'
  end

  describe 'get service_provider_source_identity_providers_report' do
    let(:action) do
      'service_provider_reports#source_identity_providers_report'
    end

    let(:path) { '/service_provider_source_identity_providers_report' }

    it_behaves_like 'post request'
  end
end
