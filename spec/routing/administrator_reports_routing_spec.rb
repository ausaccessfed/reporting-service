require 'rails_helper'

RSpec.describe AdministratorReportsController, type: :routing do
  shared_examples 'get request' do
    subject { { get: "admin/reports#{path}" } }

    it { is_expected.to route_to("administrator_reports#{action}") }
  end

  shared_examples 'post request' do
    subject { { post: "admin/reports#{path}" } }

    it { is_expected.to route_to("administrator_reports#{action}") }
  end

  describe 'get on /admin/reports' do
    let(:action) { '#index' }
    let(:path) { '/' }

    it_behaves_like 'get request'
  end

  describe 'get on /admin/reports/subscriber_registrations_report' do
    let(:action) { '#subscriber_registrations_report' }
    let(:path) { '/subscriber_registrations_report' }

    it_behaves_like 'get request'
  end

  describe 'post & get on /admin/reports/subscriber_registrations_report' do
    let(:action) { '#subscriber_registrations_report' }
    let(:path) { '/subscriber_registrations_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /admin/reports/federation_growth_report' do
    let(:action) { '#federation_growth_report' }
    let(:path) { '/federation_growth_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /admin/reports/federation_growth_report' do
    let(:action) { '#federation_growth_report' }
    let(:path) { '/federation_growth_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /admin/reports/daily_demand_report' do
    let(:action) { '#daily_demand_report' }
    let(:path) { '/daily_demand_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /admin/reports/daily_demand_report' do
    let(:action) { '#daily_demand_report' }
    let(:path) { '/daily_demand_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /admin/reports/federated_sessions_report' do
    let(:action) { '#federated_sessions_report' }
    let(:path) { '/federated_sessions_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /admin/reports/federated_sessions_report' do
    let(:action) { '#federated_sessions_report' }
    let(:path) { '/federated_sessions_report' }

    it_behaves_like 'post request'
  end
end
