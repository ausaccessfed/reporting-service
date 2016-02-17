require 'rails_helper'

RSpec.feature 'automated report instances' do
  include IdentityEnhancementStub
  given(:user) { create :subject }
  given(:organization) { create :organization }

  given(:idp) do
    create :identity_provider,
           organization: organization
  end

  given(:sp) do
    create :service_provider,
           organization: organization
  end

  given(:auto_report_idp) do
    create :automated_report,
           target: idp.entity_id,
           report_class: 'IdentityProviderSessionsReport'
  end

  given(:auto_report_sp) do
    create :automated_report,
           target: sp.entity_id,
           report_class: 'ServiceProviderDailyDemandReport'
  end

  given(:auto_report_admin) do
    create :automated_report,
           target: 'organizations',
           report_class: 'SubscriberRegistrationsReport'
  end

  given!(:report_instance_idp) do
    create :automated_report_instance,
           automated_report: auto_report_idp
  end

  given!(:report_instance_sp) do
    create :automated_report_instance,
           automated_report: auto_report_sp
  end

  given!(:report_instance_admin) do
    create :automated_report_instance,
           automated_report: auto_report_admin
  end

  def show_not_allowed_message
    message = 'Oops, you clicked something we didn\'t'\
              ' expect you to click'

    expect(page).to have_selector('p', text: message)
  end

  describe 'subject has subscriber permission' do
    background do
      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      identifier = organization.identifier
      entitlements =
        "urn:mace:aaf.edu.au:ide:internal:organization:#{identifier}"

      stub_ide(shared_token: user.shared_token, entitlements: [entitlements])

      visit '/auth/login'
      click_button 'Login'
    end

    scenario 'viewing automated_report_instances#show' do
      identifier_idp = report_instance_idp.identifier
      identifier_sp = report_instance_sp .identifier

      visit "/automated_reports/#{identifier_idp}"
      expect(current_path).to eq("/automated_reports/#{identifier_idp}")
      expect(page).to have_css('#output svg.identity-provider-sessions')

      visit "/automated_reports/#{identifier_sp}"
      expect(current_path).to eq("/automated_reports/#{identifier_sp}")
      expect(page).to have_css('#output svg.service-provider-daily-demand')
    end
  end

  describe 'subject has no permissions' do
    given!(:auto_report) do
      create :automated_report,
             report_class: 'DailyDemandReport'
    end

    given(:subscription) do
      create :automated_report_subscription,
             automated_report: auto_report,
             subject: user
    end

    given!(:auto_report_intance) do
      create :automated_report_instance,
             automated_report: auto_report
    end

    background do
      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      stub_ide(shared_token: user.shared_token, entitlements: [nil])

      visit '/auth/login'
      click_button 'Login'
    end

    scenario 'viewing automated_report_instances#show' do
      identifier_idp = report_instance_idp.identifier
      identifier_sp = report_instance_sp .identifier
      identifier = auto_report_intance.identifier

      visit "/automated_reports/#{identifier_idp}"
      expect(current_path).to eq("/automated_reports/#{identifier_idp}")
      show_not_allowed_message

      visit "/automated_reports/#{identifier_sp}"
      expect(current_path).to eq("/automated_reports/#{identifier_sp}")
      show_not_allowed_message

      visit "/automated_reports/#{identifier}"
      expect(current_path).to eq("/automated_reports/#{identifier}")
      expect(page).to have_css('#output svg.daily-demand')
    end
  end
end
