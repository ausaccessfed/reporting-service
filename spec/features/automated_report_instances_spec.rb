# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'automated report instances' do
  let(:user) { create(:subject) }
  let(:organization) { create(:organization) }
  let(:attribute) { create(:saml_attribute) }
  let(:idp) { create(:identity_provider, organization:) }
  let(:unknown_idp) { create(:identity_provider) }
  let(:sp) { create(:service_provider, organization:) }
  let(:unknown_sp) { create(:service_provider) }

  let(:svg_templates) do
    'ServiceProviderDailyDemandReport ServiceProviderSessionsReport
      IdentityProviderDailyDemandReport IdentityProviderSessionsReport
      IdentityProviderAttributesReport DailyDemandReport
      FederatedSessionsReport FederationGrowthReport'
  end

  def get_tamplate_name(type)
    type.chomp('Report').underscore.tr('_', '-')
  end

  shared_examples 'Automated Public Report' do
    let(:auto_report) { create(:automated_report, target:, report_class:, source:) }

    let!(:instance) { create(:automated_report_instance, automated_report: auto_report) }

    before do
      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      visit '/auth/login'
      click_button 'Login'
    end

    it 'viewing automated_report_instances#show' do
      template = get_tamplate_name report_class
      prefix = svg_templates.include?(report_class) ? 'svg' : 'table'

      visit "/automated_report/#{instance.identifier}"
      expect(page).to have_current_path("/automated_report/#{instance.identifier}", ignore_query: true)
      expect(page).to have_css("#output #{prefix}.#{template}")
      # For reports that depend on session source, check the right one was used.
      expect(page).to have_content("(#{source_name})") if defined?(source_name)
    end
  end

  context 'Federation Growth Report' do
    let(:report_class) { 'FederationGrowthReport' }
    let(:source) { nil }
    let(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  shared_examples 'Federated Sessions Report' do
    let(:report_class) { 'FederatedSessionsReport' }
    let(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  shared_examples 'Daily Demand Report' do
    let(:report_class) { 'DailyDemandReport' }
    let(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  context 'Identity Provider Attributes Report' do
    let(:report_class) { 'IdentityProviderAttributesReport' }
    let(:source) { nil }
    let(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  context 'Provided Attribute Report Report' do
    let(:report_class) { 'ProvidedAttributeReport' }
    let(:source) { nil }
    let(:target) { attribute.name }

    it_behaves_like 'Automated Public Report'
  end

  context 'Requested Attribute Report' do
    let(:report_class) { 'RequestedAttributeReport' }
    let(:source) { nil }
    let(:target) { attribute.name }

    it_behaves_like 'Automated Public Report'
  end

  context 'Automated Federation Service Compatibility Report' do
    let(:target) { sp.entity_id }
    let(:report_class) { 'ServiceCompatibilityReport' }
    let(:source) { nil }

    it_behaves_like 'Automated Public Report'
  end

  shared_examples 'Automated Subscriber Report' do
    let(:auto_report) { create(:automated_report, target: object.entity_id, report_class:, source:) }

    let!(:instance) { create(:automated_report_instance, automated_report: auto_report) }

    let!(:unknown_auto_report) { create(:automated_report, target: unknown_object.entity_id, report_class:, source:) }

    let!(:unknown_instance) { create(:automated_report_instance, automated_report: unknown_auto_report) }

    before do
      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      identifier = organization.identifier
      entitlements = ["urn:mace:aaf.edu.au:ide:internal:organization:#{identifier}"]

      admins = Rails.application.config.reporting_service.admins
      admins[user.shared_token.to_sym] = entitlements

      visit '/auth/login'
      click_button 'Login'
    end

    it 'viewing automated_report_instances#show' do
      template = get_tamplate_name report_class
      prefix = svg_templates.include?(report_class) ? 'svg' : 'table'
      unknown_identifier = unknown_instance.identifier

      visit "/automated_report/#{instance.identifier}"
      expect(page).to have_current_path("/automated_report/#{instance.identifier}", ignore_query: true)
      expect(page).to have_css("#output #{prefix}.#{template}")

      # For reports that depend on session source, check the right one was used.
      if defined?(source_name)
        # Tabular reports do not render report title - see #178
        # So instead just confirm the report-data JSON contains the title.
        report_data = page.evaluate_script('document.getElementsByClassName("report-data")[0].innerHTML')
        expect(report_data).to have_text("(#{source_name})")
      end

      visit "/automated_report/#{unknown_instance.identifier}"
      expect(page).to have_current_path("/automated_report/#{unknown_identifier}", ignore_query: true)

      message = 'Oops, you clicked something we didn\'t expect you to click'

      expect(page).to have_css('p', text: message)
    end
  end

  shared_examples 'Identity Provider Sessions Report' do
    let(:report_class) { 'IdentityProviderSessionsReport' }
    let(:object) { idp }
    let(:unknown_object) { unknown_idp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Identity Provider Daily Demand Report' do
    let(:report_class) { 'IdentityProviderDailyDemandReport' }
    let(:object) { idp }
    let(:unknown_object) { unknown_idp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Identity Provider Destination Services Report' do
    let(:report_class) { 'IdentityProviderDestinationServicesReport' }
    let(:object) { idp }
    let(:unknown_object) { unknown_idp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Service Provider Source Identity Providers Report' do
    let(:report_class) { 'ServiceProviderSourceIdentityProvidersReport' }
    let(:object) { sp }
    let(:unknown_object) { unknown_sp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Service Provider Sessions Report' do
    let(:report_class) { 'ServiceProviderSessionsReport' }
    let(:object) { sp }
    let(:unknown_object) { unknown_sp }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Service Provider Daily Demand Report' do
    let(:report_class) { 'ServiceProviderDailyDemandReport' }
    let(:object) { sp }
    let(:unknown_object) { unknown_sp }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Automated Reports using DS session source' do
    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

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
    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

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
    let(:auto_report) { create(:automated_report, target:, report_class: 'SubscriberRegistrationsReport') }

    let!(:instance) { create(:automated_report_instance, automated_report: auto_report) }

    describe 'none admin subject' do
      before do
        attrs = create(:aaf_attributes, :from_subject, subject: user)
        RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

        identifier = organization.identifier
        entitlements = ["urn:mace:aaf.edu.au:ide:internal:organization:#{identifier}"]
        admins = Rails.application.config.reporting_service.admins
        admins[user.shared_token.to_sym] = entitlements

        visit '/auth/login'
        click_button 'Login'
      end

      it 'can not view Subscriber Registrations Report' do
        visit "/automated_report/#{instance.identifier}"
        expect(page).to have_current_path("/automated_report/#{instance.identifier}", ignore_query: true)

        message = 'Oops, you clicked something we didn\'t expect you to click'

        expect(page).to have_css('p', text: message)
      end
    end

    describe 'admin subject' do
      before do
        attrs = create(:aaf_attributes, :from_subject, subject: user)
        RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

        entitlements = ['urn:mace:aaf.edu.au:ide:internal:aaf-admin']
        admins = Rails.application.config.reporting_service.admins
        admins[user.shared_token.to_sym] = entitlements

        visit '/auth/login'
        click_button 'Login'
      end

      it 'can view Subscriber Registrations Report' do
        visit "/automated_report/#{instance.identifier}"
        expect(page).to have_current_path("/automated_report/#{instance.identifier}", ignore_query: true)
        expect(page).to have_css('#output table.subscriber-registrations')
      end
    end
  end

  context 'Subscriber Registrations Reports' do
    targets = %w[identity_providers service_providers organizations rapid_connect_services services]

    targets.each do |target|
      let(:target) { target }

      it_behaves_like 'Automated Subscriber Registrations Report'
    end
  end
end
