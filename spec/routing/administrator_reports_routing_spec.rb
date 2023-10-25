# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdministratorReportsController do
  shared_examples 'get request' do
    subject { { get: "admin_reports#{path}" } }

    it { is_expected.to route_to("administrator_reports#{action}") }
  end

  shared_examples 'post request' do
    subject { { post: "admin_reports#{path}" } }

    it { is_expected.to route_to("administrator_reports#{action}") }
  end

  describe 'get on /admin_reports' do
    let(:action) { '#index' }
    let(:path) { '/' }

    it_behaves_like 'get request'
  end

  describe 'get on /admin_reports/subscriber_registrations_report' do
    let(:action) { '#subscriber_registrations_report' }
    let(:path) { '/subscriber_registrations_report' }

    it_behaves_like 'get request'
  end

  describe 'post & get on /admin_reports/subscriber_registrations_report' do
    let(:action) { '#subscriber_registrations_report' }
    let(:path) { '/subscriber_registrations_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /admin_reports/federation_growth_report' do
    let(:action) { '#federation_growth_report' }
    let(:path) { '/federation_growth_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /admin_reports/federation_growth_report' do
    let(:action) { '#federation_growth_report' }
    let(:path) { '/federation_growth_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /admin_reports/daily_demand_report' do
    let(:action) { '#daily_demand_report' }
    let(:path) { '/daily_demand_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /admin_reports/daily_demand_report' do
    let(:action) { '#daily_demand_report' }
    let(:path) { '/daily_demand_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /admin_reports/federated_sessions_report' do
    let(:action) { '#federated_sessions_report' }
    let(:path) { '/federated_sessions_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /admin_reports/federated_sessions_report' do
    let(:action) { '#federated_sessions_report' }
    let(:path) { '/federated_sessions_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /admin_reports/identity_provider_utilization_report' do
    let(:action) { '#identity_provider_utilization_report' }
    let(:path) { '/identity_provider_utilization_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /admin_reports/identity_provider_utilization_report' do
    let(:action) { '#identity_provider_utilization_report' }
    let(:path) { '/identity_provider_utilization_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /admin_reports/service_provider_utilization_report' do
    let(:action) { '#service_provider_utilization_report' }
    let(:path) { '/service_provider_utilization_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /admin_reports/service_provider_utilization_report' do
    let(:action) { '#service_provider_utilization_report' }
    let(:path) { '/service_provider_utilization_report' }

    it_behaves_like 'post request'
  end
end
