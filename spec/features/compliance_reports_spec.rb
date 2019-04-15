# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Compliance Reports' do
  given(:user) { create(:subject) }
  given(:sp) { create :service_provider }
  given(:idp) { create :identity_provider }
  given(:controller) { 'compliance_reports' }

  background do
    create_list :service_provider_saml_attribute, 5, service_provider: sp
    create_list :identity_provider_saml_attribute, 5, identity_provider: idp
    create(:activation, federation_object: sp)
    create(:activation, federation_object: idp)

    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'
  end

  scenario 'viewing the Service Compatibility Report' do
    click_link 'Service Compatibility Report'

    select sp.name, from: 'Service Providers'
    click_button 'Generate'

    expect(page).to have_css('#output table.service-compatibility')
  end

  scenario 'viewing the Identity Provider Attributes Report' do
    click_link 'Identity Provider Attributes'

    expect(page).to have_css('#output svg.identity-provider-attributes')
  end

  scenario 'viewing the Single Attribute Report – Identity Providers Report' do
    click_link 'Single Attribute Report – Identity Providers'

    select idp.saml_attributes.sample.name, from: 'Attribute'
    click_button 'Generate'
    expect(page).to have_css('#output table.provided-attribute')
  end

  scenario 'viewing the Single Attribute Report – Service Providers Report' do
    click_link 'Single Attribute Report – Service Providers'

    select sp.saml_attributes.sample.name, from: 'Attribute'
    click_button 'Generate'
    expect(page).to have_css('#output table.requested-attribute')
  end

  context 'Identity Provider Attributes Report' do
    given(:button) { 'Identity Provider Attributes Report' }
    given(:report_class) { 'IdentityProviderAttributesReport' }
    given(:source) { nil }
    given(:path) { 'identity_provider_attributes_report' }
    given(:template) { 'svg.identity-provider-attributes' }

    it_behaves_like 'Subscribing to a nil class report'
  end

  context 'Single Attributes Service Provider Report' do
    given(:object) { sp.saml_attributes.sample }
    given(:target) { object.name }
    given(:list) { 'Attributes' }
    given(:button) { 'Single Attribute Report – Service Providers' }
    given(:report_class) { 'RequestedAttributeReport' }
    given(:source) { nil }
    given(:path) { 'attribute_service_providers_report' }

    it_behaves_like 'Subscribing to an automated report with target'
  end

  context 'Single Attributes Service Provider Report' do
    given(:object) { sp.saml_attributes.sample }
    given(:target) { object.name }
    given(:list) { 'Attributes' }
    given(:button) { 'Single Attribute Report – Identity Providers' }
    given(:report_class) { 'ProvidedAttributeReport' }
    given(:source) { nil }
    given(:path) { 'attribute_identity_providers_report' }

    it_behaves_like 'Subscribing to an automated report with target'
  end

  context 'Service Compatibility Report' do
    given(:target) { sp.entity_id }
    given(:object) { sp }
    given(:list) { 'Service Provider' }
    given(:button) { 'Service Compatibility Report' }
    given(:report_class) { 'ServiceCompatibilityReport' }
    given(:source) { nil }
    given(:path) { 'service_provider_compatibility_report' }

    it_behaves_like 'Subscribing to an automated report with target'
  end
end
