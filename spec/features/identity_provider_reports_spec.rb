require 'rails_helper'

RSpec.feature 'Identity Provider Reports' do
  include IdentityEnhancementStub

  given(:organization) { create :organization }
  given(:idp) { create :identity_provider, organization: organization }
  given(:user) { create :subject }

  given(:not_allowed_message) do
    'Sorry, your organization did not allow you to generate reports'\
    ' for any Identity Provider'
  end

  def show_not_allowed_message
    expect(page).to have_selector('p', not_allowed_message)
  end

  describe 'subject has permissions' do
    background do
      create :activation, federation_object: idp

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

    scenario 'viewing the IdP Sessions Report' do
      click_link('Identity Provider Sessions Report')

      expect(current_path)
        .to eq('/subscriber_reports/identity_provider/sessions_report')

      select idp.name, from: 'Identity Providers'
      fill_in 'start', with: 1.year.ago
      fill_in 'end', with: Time.zone.now

      click_button 'Generate'

      expect(current_path)
        .to eq('/subscriber_reports/identity_provider/sessions_report')
      expect(page).to have_css('svg.identity-provider-sessions')
    end

    scenario 'viewing the IdP Daily Demand Report' do
      click_link('Identity Provider Daily Demand Report')

      expect(current_path)
        .to eq('/subscriber_reports/identity_provider/daily_demand_report')

      select idp.name, from: 'Identity Providers'
      fill_in 'start', with: 1.year.ago
      fill_in 'end', with: Time.zone.now

      click_button 'Generate'

      expect(current_path).to eq('/subscriber_reports/identity_provider/'\
                                 'daily_demand_report')
      expect(page).to have_css('svg.identity-provider-daily-demand')
    end

    scenario 'viewing the Destination Services Report' do
      click_link('Identity Provider Destination Services Report')

      expect(current_path)
        .to eq('/subscriber_reports/identity_provider/'\
               'destination_services_report')

      select idp.name, from: 'Identity Providers'
      fill_in 'start', with: 1.year.ago
      fill_in 'end', with: Time.zone.now

      click_button 'Generate'

      expect(current_path)
        .to eq('/subscriber_reports/identity_provider/'\
               'destination_services_report')
    end
  end

  describe 'subject has no permissions' do
    background do
      create :activation, federation_object: idp

      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      stub_ide(shared_token: user.shared_token, entitlements: [nil])
      stub_ide(shared_token: user.shared_token)

      visit '/auth/login'
      click_button 'Login'
      visit '/subscriber_reports'
    end

    scenario 'viewing the IdP Destination Services Report' do
      visit '/subscriber_reports/identity_provider/sessions_report'
      show_not_allowed_message

      visit '/subscriber_reports/identity_provider/daily_demand_report'
      show_not_allowed_message

      visit '/subscriber_reports/identity_provider/destination_services_report'
      show_not_allowed_message
    end
  end
end
