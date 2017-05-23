# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Federation Reports' do
  given(:user) { create(:subject) }
  given(:controller) { 'federation_reports' }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)

    visit '/auth/login'
    click_button 'Login'
  end

  scenario 'users will be redirected to dashboard after login' do
    expect(current_path).to eq('/dashboard')
  end

  context 'Federation Growth Report' do
    given(:button) { 'Federation Growth Report' }
    given(:path) { 'federation_growth_report' }
    given(:report_class) { 'FederationGrowthReport' }
    given(:template) { 'svg.federation-growth' }

    it_behaves_like 'Subscribing to a nil class report'
  end

  context 'Federated Sessions Report' do
    given(:button) { 'Federated Sessions Report' }
    given(:report_class) { 'FederatedSessionsReport' }
    given(:path) { 'federated_sessions_report' }
    given(:template) { 'svg.federated-sessions' }

    it_behaves_like 'Subscribing to a nil class report'
  end

  context 'Daily Demand Report' do
    given(:button) { 'Daily Demand Report' }
    given(:report_class) { 'DailyDemandReport' }
    given(:path) { 'daily_demand_report' }
    given(:template) { 'svg.daily-demand' }

    it_behaves_like 'Subscribing to a nil class report'
  end
end
