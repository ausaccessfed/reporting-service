# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Federation Reports' do
  let(:user) { create(:subject) }
  let(:controller) { 'federation_reports' }

  before do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'
  end

  it 'users will be redirected to dashboard after login' do
    expect(page).to have_current_path('/dashboard', ignore_query: true)
  end

  context 'Federation Growth Report' do
    let(:button) { 'Federation Growth Report' }
    let(:path) { 'federation_growth_report' }
    let(:report_class) { 'FederationGrowthReport' }
    let(:source) { nil }
    let(:template) { 'svg.federation-growth' }

    it_behaves_like 'Subscribing to a nil class report'
  end

  context 'Federated Sessions Report' do
    let(:button) { 'Federated Sessions Report' }
    let(:report_class) { 'FederatedSessionsReport' }
    let(:source) { 'DS' }
    let(:path) { 'federated_sessions_report' }
    let(:template) { 'svg.federated-sessions' }

    it_behaves_like 'Subscribing to a nil class report'
  end

  context 'Daily Demand Report' do
    let(:button) { 'Daily Demand Report' }
    let(:report_class) { 'DailyDemandReport' }
    let(:source) { 'DS' }
    let(:path) { 'daily_demand_report' }
    let(:template) { 'svg.daily-demand' }

    it_behaves_like 'Subscribing to a nil class report'
  end
end
