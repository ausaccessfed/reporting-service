# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'automated report instances' do
  given(:user) { create :subject }
  given(:organization) { create :organization }
  given(:attribute) { create :saml_attribute }
  given(:idp) { create :identity_provider, organization: }
  given(:unknown_idp) { create :identity_provider }
  given(:sp) { create :service_provider, organization: }
  given(:unknown_sp) { create :service_provider }

  given(:svg_templates) do
    'ServiceProviderDailyDemandReport ServiceProviderSessionsReport
      IdentityProviderDailyDemandReport IdentityProviderSessionsReport
      IdentityProviderAttributesReport DailyDemandReport
      FederatedSessionsReport FederationGrowthReport'
  end

  def get_tamplate_name(type)
    type.chomp('Report').underscore.tr('_', '-')
  end

  shared_examples 'Automated Public Report' do
    given(:auto_report) { create :automated_report, target:, report_class:, source: }

    given!(:instance) { create :automated_report_instance, automated_report: auto_report }

    background do
      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      visit '/auth/login'
      click_button 'Login'
    end

    scenario 'viewing automated_report_instances#show' do
      template = get_tamplate_name report_class
      prefix = svg_templates.include?(report_class) ? 'svg' : 'table'

      visit "/automated_report/#{instance.identifier}"
      expect(current_path).to eq("/automated_report/#{instance.identifier}")
      expect(page).to have_css("#output #{prefix}.#{template}")
      # For reports that depend on session source, check the right one was used.
      expect(page).to have_content("(#{source_name})") if defined?(source_name)
    end
  end

  context 'Federation Growth Report' do
    given(:report_class) { 'FederationGrowthReport' }
    given(:source) { nil }
    given(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  shared_examples 'Federated Sessions Report' do
    given(:report_class) { 'FederatedSessionsReport' }
    given(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  shared_examples 'Daily Demand Report' do
    given(:report_class) { 'DailyDemandReport' }
    given(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  context 'Identity Provider Attributes Report' do
    given(:report_class) { 'IdentityProviderAttributesReport' }
    given(:source) { nil }
    given(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  context 'Provided Attribute Report Report' do
    given(:report_class) { 'ProvidedAttributeReport' }
    given(:source) { nil }
    given(:target) { attribute.name }

    it_behaves_like 'Automated Public Report'
  end

  context 'Requested Attribute Report' do
    given(:report_class) { 'RequestedAttributeReport' }
    given(:source) { nil }
    given(:target) { attribute.name }

    it_behaves_like 'Automated Public Report'
  end

  context 'Automated Federation Service Compatibility Report' do
    given(:target) { sp.entity_id }
    given(:report_class) { 'ServiceCompatibilityReport' }
    given(:source) { nil }

    it_behaves_like 'Automated Public Report'
  end

  shared_examples 'Automated Subscriber Report' do
    given(:auto_report) { create :automated_report, target: object.entity_id, report_class:, source: }

    given!(:instance) { create :automated_report_instance, automated_report: auto_report }

    given!(:unknown_auto_report) { create :automated_report, target: unknown_object.entity_id, report_class:, source: }

    given!(:unknown_instance) { create :automated_report_instance, automated_report: unknown_auto_report }

    background do
      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      identifier = organization.identifier
      entitlements = ["urn:mace:aaf.edu.au:ide:internal:organization:#{identifier}"]

      admins = Rails.application.config.reporting_service.admins
      admins[user.shared_token.to_sym] = entitlements

      visit '/auth/login'
      click_button 'Login'
    end

    scenario 'viewing automated_report_instances#show' do
      template = get_tamplate_name report_class
      prefix = svg_templates.include?(report_class) ? 'svg' : 'table'
      unknown_identifier = unknown_instance.identifier

      visit "/automated_report/#{instance.identifier}"
      expect(current_path).to eq("/automated_report/#{instance.identifier}")
      expect(page).to have_css("#output #{prefix}.#{template}")

      # For reports that depend on session source, check the right one was used.
      if defined?(source_name)
        # Tabular reports do not render report title - see #178
        # So instead just confirm the report-data JSON contains the title.
        report_data = page.evaluate_script('document.getElementsByClassName("report-data")[0].innerHTML')
        expect(report_data).to have_text("(#{source_name})")
      end

      visit "/automated_report/#{unknown_instance.identifier}"
      expect(current_path).to eq("/automated_report/#{unknown_identifier}")

      message = 'Oops, you clicked something we didn\'t expect you to click'

      expect(page).to have_selector('p', text: message)
    end
  end

  shared_examples 'Identity Provider Sessions Report' do
    given(:report_class) { 'IdentityProviderSessionsReport' }
    given(:object) { idp }
    given(:unknown_object) { unknown_idp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Identity Provider Daily Demand Report' do
    given(:report_class) { 'IdentityProviderDailyDemandReport' }
    given(:object) { idp }
    given(:unknown_object) { unknown_idp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Identity Provider Destination Services Report' do
    given(:report_class) { 'IdentityProviderDestinationServicesReport' }
    given(:object) { idp }
    given(:unknown_object) { unknown_idp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Service Provider Source Identity Providers Report' do
    given(:report_class) { 'ServiceProviderSourceIdentityProvidersReport' }
    given(:object) { sp }
    given(:unknown_object) { unknown_sp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Service Provider Sessions Report' do
    given(:report_class) { 'ServiceProviderSessionsReport' }
    given(:object) { sp }
    given(:unknown_object) { unknown_sp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Service Provider Daily Demand Report' do
    given(:report_class) { 'ServiceProviderDailyDemandReport' }
    given(:object) { sp }
    given(:unknown_object) { unknown_sp }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Automated Reports using DS session source' do
    given(:source) { 'DS' }
    given(:source_name) { 'Discovery Service' }

    it_behaves_like 'Federated Sessions Report'
    it_behaves_like 'Daily Demand Report'
    it_behaves_like 'Identity Provider Sessions Report'
    it_behaves_like 'Identity Provider Daily Demand Report'
    it_behaves_like 'Identity Provider Destination Services Report'
    it_behaves_like 'Service Provider Source Identity Providers Report'
    it_behaves_like 'Service Provider Sessions Report'
    it_behaves_like 'Service Provider Daily Demand Report'
  end

  context 'Automated Reports using IdP session source' do
    given(:source) { 'IdP' }
    given(:source_name) { 'IdP Event Log' }

    it_behaves_like 'Federated Sessions Report'
    it_behaves_like 'Daily Demand Report'
    it_behaves_like 'Identity Provider Sessions Report'
    it_behaves_like 'Identity Provider Daily Demand Report'
    it_behaves_like 'Identity Provider Destination Services Report'
    it_behaves_like 'Service Provider Source Identity Providers Report'
    it_behaves_like 'Service Provider Sessions Report'
    it_behaves_like 'Service Provider Daily Demand Report'
  end

  shared_examples 'Automated Subscriber Registrations Report' do
    given(:auto_report) { create :automated_report, target:, report_class: 'SubscriberRegistrationsReport' }

    given!(:instance) { create :automated_report_instance, automated_report: auto_report }

    describe 'none admin subject' do
      background do
        attrs = create(:aaf_attributes, :from_subject, subject: user)
        RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

        identifier = organization.identifier
        entitlements = ["urn:mace:aaf.edu.au:ide:internal:organization:#{identifier}"]
        admins = Rails.application.config.reporting_service.admins
        admins[user.shared_token.to_sym] = entitlements

        visit '/auth/login'
        click_button 'Login'
      end

      scenario 'can not view Subscriber Registrations Report' do
        visit "/automated_report/#{instance.identifier}"
        expect(current_path).to eq("/automated_report/#{instance.identifier}")

        message = 'Oops, you clicked something we didn\'t expect you to click'

        expect(page).to have_selector('p', text: message)
      end
    end

    describe 'admin subject' do
      background do
        attrs = create(:aaf_attributes, :from_subject, subject: user)
        RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

        entitlements = ['urn:mace:aaf.edu.au:ide:internal:aaf-admin']
        admins = Rails.application.config.reporting_service.admins
        admins[user.shared_token.to_sym] = entitlements

        visit '/auth/login'
        click_button 'Login'
      end

      scenario 'can view Subscriber Registrations Report' do
        visit "/automated_report/#{instance.identifier}"
        expect(current_path).to eq("/automated_report/#{instance.identifier}")
        expect(page).to have_css('#output table.subscriber-registrations')
      end
    end
  end

  context 'Subscriber Registrations Reports' do
    targets = %w[identity_providers service_providers organizations rapid_connect_services services]

    targets.each do |target|
      given(:target) { target }

      it_behaves_like 'Automated Subscriber Registrations Report'
    end
  end
end
