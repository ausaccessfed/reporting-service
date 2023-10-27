# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Identity Provider Reports' do
  let(:organization) { create(:organization) }
  let(:idp) { create(:identity_provider, organization:) }
  let(:user) { create(:subject) }

  describe 'subject with permissions' do
    before do
      create(:activation, federation_object: idp)

      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      identifier = organization.identifier
      entitlements = ["urn:mace:aaf.edu.au:ide:internal:organization:#{identifier}"]
      admins = Rails.application.config.reporting_service.admins
      admins[user.shared_token.to_sym] = entitlements

      visit '/auth/login'
      click_button 'Login'
      visit '/subscriber_reports'
    end

    shared_examples 'viewing reports depending on session source' do
      it 'viewing the IdP Sessions Report' do
        click_link('Identity Provider Sessions Report')

        expect(page).to have_current_path('/subscriber_reports/identity_provider_sessions_report', ignore_query: true)

        select idp.name, from: 'Identity Providers'

        page.execute_script("$('input').removeAttr('readonly')")

        fill_in 'start', with: 1.year.ago
        fill_in 'end', with: Time.zone.now
        select data_source_name, from: 'source'

        page.find_button('Generate').execute_script('this.click()')
        sleep(2)

        expect(page).to have_current_path('/subscriber_reports/identity_provider_sessions_report', ignore_query: true)
        expect(page).to have_css('svg.identity-provider-sessions')
        expect(page).to have_content("(#{data_source_name})")
      end

      it 'viewing the IdP Daily Demand Report' do
        click_link('Identity Provider Daily Demand Report')

        expect(page).to have_current_path('/subscriber_reports/identity_provider_daily_demand_report', 
ignore_query: true)

        select idp.name, from: 'Identity Providers'

        page.execute_script("$('input').removeAttr('readonly')")

        fill_in 'start', with: 1.year.ago
        fill_in 'end', with: Time.zone.now
        select data_source_name, from: 'source'

        page.find_button('Generate').execute_script('this.click()')
        sleep(2)

        expect(page).to have_current_path(
          '/subscriber_reports/identity_provider_' \
            'daily_demand_report', ignore_query: true
        )
        expect(page).to have_css('svg.identity-provider-daily-demand')
        expect(page).to have_content("(#{data_source_name})")
      end

      it 'viewing the Destination Services Report' do
        click_link('Identity Provider Destination Services Report')

        expect(page).to have_current_path(
          '/subscriber_reports/identity_provider_' \
            'destination_services_report', ignore_query: true
        )

        select idp.name, from: 'Identity Providers'

        page.execute_script("$('input').removeAttr('readonly')")

        fill_in 'start', with: 1.year.ago
        fill_in 'end', with: Time.zone.now
        select data_source_name, from: 'source'

        page.find_button('Generate').execute_script('this.click()')
        sleep(2)

        expect(page).to have_current_path(
          '/subscriber_reports/identity_provider_' \
            'destination_services_report', ignore_query: true
        )
        # Tabular reports do not render report title - see #178
        # So instead just confirm the report-data JSON contains the title.
        report_data = page.evaluate_script('document.getElementsByClassName("report-data")[0].innerHTML')
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
    before do
      create(:activation, federation_object: idp)

      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      visit '/auth/login'
      click_button 'Login'
      visit '/subscriber_reports'
    end

    it 'can not view the IdP Destination Services Report' do
      message =
        'Sorry, it seems there are no identity providers available! ' \
          'or your organization did not allow you to generate ' \
          'reports for any identity providers'

      visit '/subscriber_reports/identity_provider_sessions_report'
      expect(page).to have_css('p', text: message)

      visit '/subscriber_reports/identity_provider_daily_demand_report'
      expect(page).to have_css('p', text: message)

      visit '/subscriber_reports/identity_provider_destination_services_report'
      expect(page).to have_css('p', text: message)
    end
  end
end
