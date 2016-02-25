require 'rails_helper'

RSpec.feature 'Service Provider Reports' do
  include IdentityEnhancementStub

  given(:organization) { create :organization }
  given(:sp) { create :service_provider, organization: organization }
  given(:user) { create :subject }

  def show_not_allowed_message
    message = 'Sorry, it seems your organization did not allow you to'\
              ' generate reports for any Service Providers'

    expect(page).to have_selector('p', text: message)
  end

  describe 'subject has permissions' do
    background do
      create :activation, federation_object: sp

      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      identifier = organization.identifier
      entitlements =
        "urn:mace:aaf.edu.au:ide:internal:organization:#{identifier}"

      stub_ide(shared_token: user.shared_token, entitlements: [entitlements])

      visit '/auth/login'
      click_button 'Login'
      visit '/subscriber_reports'
    end

    scenario 'viewing the SP Sessions Report' do
      click_link('Service Provider Sessions Report')

      expect(current_path)
        .to eq('/subscriber_reports/service_provider_sessions_report')

      select sp.name, from: 'Service Providers'
      fill_in 'start', with: 1.year.ago
      fill_in 'end', with: Time.zone.now

      click_button 'Generate'

      expect(current_path)
        .to eq('/subscriber_reports/service_provider_sessions_report')
      expect(page).to have_css('svg.service-provider-sessions')
    end

    scenario 'viewing the SP Daily Demand Report' do
      click_link('Service Provider Daily Demand Report')

      expect(current_path)
        .to eq('/subscriber_reports/service_provider_daily_demand_report')

      select sp.name, from: 'Service Providers'
      fill_in 'start', with: 1.year.ago
      fill_in 'end', with: Time.zone.now

      click_button 'Generate'

      expect(current_path).to eq('/subscriber_reports/service_provider_'\
                                 'daily_demand_report')
      expect(page).to have_css('svg.service-provider-daily-demand')
    end

    scenario 'viewing the SP Source Identity Providers Report' do
      click_link('Service Provider Source Identity Providers Report')

      expect(current_path)
        .to eq('/subscriber_reports/service_provider_'\
               'source_identity_providers_report')

      select sp.name, from: 'Service Providers'
      fill_in 'start', with: 1.year.ago.utc
      fill_in 'end', with: Time.now.utc

      click_button 'Generate'

      expect(current_path)
        .to eq('/subscriber_reports/service_provider_'\
               'source_identity_providers_report')
    end
  end

  describe 'Subject without permissions' do
    background do
      create :activation, federation_object: sp

      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      stub_ide(shared_token: user.shared_token, entitlements: [nil])
      stub_ide(shared_token: user.shared_token)

      visit '/auth/login'
      click_button 'Login'
      visit '/subscriber_reports'
    end

    scenario 'can not view the SP Source Identity Providers Report' do
      visit '/subscriber_reports/service_provider_sessions_report'
      show_not_allowed_message

      visit '/subscriber_reports/service_provider_daily_demand_report'
      show_not_allowed_message

      visit '/subscriber_reports/service_provider_'\
            'source_identity_providers_report'
      show_not_allowed_message
    end
  end
end
