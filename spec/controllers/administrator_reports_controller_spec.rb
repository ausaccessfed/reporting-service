# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdministratorReportsController, type: :controller do
  let(:user) { create(:subject, :authorized, permission: 'admin:*') }

  let(:range) { { start: Time.now.utc - 1.month, end: Time.now.utc } }

  let(:source) do
    # TODO: test with other sources?
    { source: 'DS' }
  end

  subject { response }

  before { session[:subject_id] = user.try(:id) }

  shared_examples 'an admin report' do
    before do
      get action
      post action, params:
    end

    it 'Assigns report data to template' do
      expect(assigns[:data]).to be_a(String)
      data = JSON.parse(assigns[:data], symbolize_names: true)
      expect(data[:type]).to eq(template)
    end
  end

  context '#index' do
    before { get :index }

    context 'when user is not administrator' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status('403') }
    end

    context 'when user is administrator' do
      it { is_expected.to have_http_status(:ok) }
    end
  end

  context 'generate Subscriber Registrations Report' do
    let(:params) { { identifier: 'organizations' } }
    let(:template) { 'subscriber-registrations' }
    let(:action) { 'subscriber_registrations_report' }

    it_behaves_like 'an admin report'
  end

  context 'generate Federation Growth Report' do
    let(:params) { range }
    let(:template) { 'federation-growth' }
    let(:action) { 'federation_growth_report' }

    it_behaves_like 'an admin report'
  end

  context 'generate Daily Demand Report' do
    let(:params) { range.merge(source) }
    let(:template) { 'daily-demand' }
    let(:action) { 'daily_demand_report' }

    it_behaves_like 'an admin report'
  end

  context 'generate Federated Sessions Report' do
    let(:params) { range.merge(source) }
    let(:template) { 'federated-sessions' }
    let(:action) { 'federated_sessions_report' }

    it_behaves_like 'an admin report'
  end

  context 'steps should scale correctly' do
    let(:params) { source }
    let(:path) { :federated_sessions_report }

    it_behaves_like 'report with scalable steps'
  end

  context 'generate Identity Provider Utilization Report' do
    let(:params) { range.merge(source) }
    let(:template) { 'identity-provider-utilization' }
    let(:action) { 'identity_provider_utilization_report' }

    it_behaves_like 'an admin report'
  end

  context 'generate Service Provider Utilization Report' do
    let(:params) { range.merge(source) }
    let(:template) { 'service-provider-utilization' }
    let(:action) { 'service_provider_utilization_report' }

    it_behaves_like 'an admin report'
  end
end
