# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Service Provider Reports' do
  given(:organization) { create :organization }
  given(:sp) { create :service_provider, organization: }
  given(:user) { create :subject }

  describe 'subject has permissions' do
    background do
      create :activation, federation_object: sp

      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      identifier = organization.identifier
      entitlements =
        ["urn:mace:aaf.edu.au:ide:internal:organization:#{identifier}"]
      admins = Rails.application.config.reporting_service.admins
      admins[user.shared_token.to_sym] = entitlements

      visit '/auth/login'
      click_button 'Login'
      visit '/subscriber_reports'
    end

    shared_examples 'viewing reports depending on session source' do
      scenario 'viewing the SP Sessions Report' do
        click_link('Service Provider Sessions Report')

        expect(current_path)
          .to eq('/subscriber_reports/service_provider_sessions_report')

        select sp.name, from: 'Service Providers'

        page.execute_script("$('input').removeAttr('readonly')")

        fill_in 'start', with: 1.year.ago
        fill_in 'end', with: Time.zone.now
        select data_source_name, from: 'source'
        page.find_button('Generate').execute_script('this.click()')
        sleep(2)

        expect(current_path)
          .to eq('/subscriber_reports/service_provider_sessions_report')
        expect(page).to have_css('svg.service-provider-sessions')
        expect(page).to have_content("(#{data_source_name})")
      end

      scenario 'viewing the SP Daily Demand Report' do
        click_link('Service Provider Daily Demand Report')

        expect(current_path)
          .to eq('/subscriber_reports/service_provider_daily_demand_report')

        select sp.name, from: 'Service Providers'

        page.execute_script("$('input').removeAttr('readonly')")

        fill_in 'start', with: 1.year.ago
        fill_in 'end', with: Time.zone.now
        select data_source_name, from: 'source'

        page.find_button('Generate').execute_script('this.click()')
        sleep(2)

        expect(current_path).to eq('/subscriber_reports/service_provider_' \
                                   'daily_demand_report')
        expect(page).to have_css('svg.service-provider-daily-demand')
        expect(page).to have_content("(#{data_source_name})")
      end

      scenario 'viewing the SP Source Identity Providers Report' do
        click_link('Service Provider Source Identity Providers Report')

        expect(current_path)
          .to eq('/subscriber_reports/service_provider_' \
                 'source_identity_providers_report')

        select sp.name, from: 'Service Providers'

        page.execute_script("$('input').removeAttr('readonly')")

        fill_in 'start', with: 1.year.ago.utc
        fill_in 'end', with: Time.now.utc
        select data_source_name, from: 'source'
        page.find_button('Generate').execute_script('this.click()')
        sleep(2)

        expect(current_path)
          .to eq('/subscriber_reports/service_provider_' \
                 'source_identity_providers_report')
        # Tabular reports do not render report title - see #178
        # So instead just confirm the report-data JSON contains the title.
        report_data = page.evaluate_script(
          'document.getElementsByClassName("report-data")[0].innerHTML'
        )
        expect(report_data).to have_text("(#{data_source_name})")
      end
    end

    context 'selecting DS session data source' do
      let(:data_source_name) { 'Discovery Service' }

      it_behaves_like 'viewing reports depending on session source'
    end

    context 'selecting IdP session data source' do
      let(:data_source_name) { 'IdP Event Log' }

      it_behaves_like 'viewing reports depending on session source'
    end
  end

  describe 'Subject without permissions' do
    background do
      create :activation, federation_object: sp

      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      visit '/auth/login'
      click_button 'Login'
      visit '/subscriber_reports'
    end

    scenario 'can not view the SP Source Identity Providers Report' do
      message = 'Sorry, it seems there are no service providers available! ' \
                'or your organization did not allow you to generate ' \
                'reports for any service providers'

      visit '/subscriber_reports/service_provider_sessions_report'
      expect(page).to have_selector('p', text: message)

      visit '/subscriber_reports/service_provider_daily_demand_report'
      expect(page).to have_selector('p', text: message)

      visit '/subscriber_reports/service_provider_' \
            'source_identity_providers_report'
      expect(page).to have_selector('p', text: message)
    end
  end
end
