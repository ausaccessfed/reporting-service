require 'rails_helper'

RSpec.feature 'Federation Reports' do
  include IdentityEnhancementStub

  given(:user) { create(:subject) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)

    visit '/auth/login'
    click_button 'Login'
  end

  scenario 'viewing the Federation Growth Report' do
    expect(current_path).to eq('/dashboard')

    click_link('Federation Growth Report')
    expect(current_path).to eq('/federation_reports/federation_growth_report')
    expect(page).to have_css('svg.federation-growth')
  end

  scenario 'viewing the Federated Sessions Report' do
    expect(current_path).to eq('/dashboard')

    click_link('Federated Sessions Report')
    expect(current_path).to eq('/federation_reports/federated_sessions_report')
    expect(page).to have_css('svg.federated-sessions')
  end

  scenario 'viewing the Daily Demand Report' do
    expect(current_path).to eq('/dashboard')

    click_link('Daily Demand Report')
    expect(current_path).to eq('/federation_reports/daily_demand_report')
    expect(page).to have_css('svg.daily-demand')
  end
end
