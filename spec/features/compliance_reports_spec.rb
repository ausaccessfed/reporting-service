require 'rails_helper'

RSpec.feature 'Compliance Reports' do
  include IdentityEnhancementStub

  given(:user) { create(:subject) }
  given!(:sp) { create(:service_provider) }
  given!(:activation) { create(:activation, federation_object: sp) }
  given!(:attribute) { create(:saml_attribute) }
  given(:controller) { 'compliance_reports' }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)

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

    select attribute.name, from: 'Attribute'
    click_button 'Generate'
    expect(page).to have_css('#output table.provided-attribute')
  end

  scenario 'viewing the Single Attribute Report – Service Providers Report' do
    click_link 'Single Attribute Report – Service Providers'

    select attribute.name, from: 'Attribute'
    click_button 'Generate'
    expect(page).to have_css('#output table.requested-attribute')
  end

  context 'Identity Provider Attributes Report' do
    given(:button) { 'Identity Provider Attributes Report' }
    given(:report_class) { 'IdentityProviderAttributesReport' }
    given(:path) { 'identity_provider_attributes_report' }
    given(:template) { 'svg.identity-provider-attributes' }

    it_behaves_like 'Subscribing to a nil class report'
  end

  context 'Single Attributes Service Provider Report' do
    given(:target) { attribute.name }
    given(:object) { attribute }
    given(:list) { 'Attributes' }
    given(:button) { 'Single Attribute Report – Service Providers' }
    given(:report_class) { 'RequestedAttributeReport' }
    given(:path) { 'attribute_service_providers_report' }

    it_behaves_like 'Subscribing to an automated report with target'
  end

  context 'Single Attributes Service Provider Report' do
    given(:target) { attribute.name }
    given(:object) { attribute }
    given(:list) { 'Attributes' }
    given(:button) { 'Single Attribute Report – Identity Providers' }
    given(:report_class) { 'ProvidedAttributeReport' }
    given(:path) { 'attribute_identity_providers_report' }

    it_behaves_like 'Subscribing to an automated report with target'
  end

  context 'Service Compatibility Report' do
    given(:target) { sp.entity_id }
    given(:object) { sp }
    given(:list) { 'Service Provider' }
    given(:button) { 'Service Compatibility Report' }
    given(:report_class) { 'ServiceCompatibilityReport' }
    given(:path) { 'service_provider_compatibility_report' }

    it_behaves_like 'Subscribing to an automated report with target'
  end
end
