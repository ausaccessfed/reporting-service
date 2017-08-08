# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutomatedReportsController, type: :controller do
  let(:idp) { create :identity_provider }
  let(:user) { create :subject }

  def destroy
    delete :destroy, params: { identifier: subscription.identifier }
  end

  def subscribe(interval)
    request.env['HTTP_REFERER'] = "federation_reports/#{path}"

    post :subscribe, params: {
      report_class: report_class, interval: interval,
      source: source,
      back_path: request.env['HTTP_REFERER']
    }.compact
  end

  before do
    session[:subject_id] = user.try(:id)
  end

  describe '#index' do
    let(:subscription) do
      create :automated_report_subscription,
             automated_report: auto_report,
             subject: user
    end

    let(:auto_report) do
      create :automated_report,
             report_class: 'IdentityProviderSessionsReport',
             source: 'DS',
             target: idp.entity_id
    end

    before do
      get :index
    end

    context 'get on /automated_reports' do
      it 'should response with 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'should render the index template' do
        expect(response).to render_template('index')
      end

      it 'should assign subject\'t automated report subscriptions' do
        expect(assigns[:subscriptions]).to include(subscription)
      end
    end

    context 'delete on /automated_reports/destroy' do
      before { destroy }

      it 'should response with redirect (302)' do
        expect(response).to redirect_to('/automated_reports')
      end

      it 'should destroy automated report subscription' do
        expect(assigns[:subscriptions]).not_to include(subscription)
      end
    end
  end

  shared_examples 'Automated Report Subscription' do
    before do
      %w[monthly quarterly yearly].each do |interval|
        subscribe interval
      end
    end

    it 'should redirect to report page with (302)' do
      expect(response).to redirect_to("federation_reports/#{path}")
      expect(user.automated_report_subscriptions.count).to eq(3)
    end
  end

  context 'Federation Growth Report' do
    let(:path) { 'federation_growth_report' }
    let(:report_class) { 'FederationGrowthReport' }
    let(:source) { nil }
    let(:template) { 'svg.federation-growth' }

    it_behaves_like 'Automated Report Subscription'
  end

  context 'Federated Sessions Report' do
    let(:path) { 'federated_sessions' }
    let(:report_class) { 'FederatedSessionsReport' }
    let(:source) { 'DS' }
    let(:template) { 'svg.federated-sessions' }

    it_behaves_like 'Automated Report Subscription'
  end

  context 'Daily Demand Report' do
    let(:path) { 'daily_demand_report' }
    let(:report_class) { 'DailyDemandReport' }
    let(:source) { 'DS' }
    let(:template) { 'svg.daily-demand_report' }

    it_behaves_like 'Automated Report Subscription'
  end
end
