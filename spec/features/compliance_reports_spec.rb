# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Compliance Reports' do
  let(:user) { create(:subject) }
  let(:sp) { create(:service_provider) }
  let(:idp) { create(:identity_provider) }
  let(:controller) { 'compliance_reports' }

  before do
    create_list(:service_provider_saml_attribute, 5, service_provider: sp)
    create_list(:identity_provider_saml_attribute, 5, identity_provider: idp)
    create(:activation, federation_object: sp)
    create(:activation, federation_object: idp)

    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'
  end

  it 'viewing the Service Compatibility Report' do
    click_link 'Service Compatibility Report'

    select sp.name, from: 'Service Providers'
    click_button 'Generate'

    expect(page).to have_css('#output table.service-compatibility')
  end

  it 'viewing the Identity Provider Attributes Report' do
    click_link 'Identity Provider Attributes'

    expect(page).to have_css('#output svg.identity-provider-attributes')
  end

  it 'viewing the Single Attribute Report – Identity Providers Report' do
    click_link 'Single Attribute Report – Identity Providers'

    select idp.saml_attributes.sample.name, from: 'Attribute'
    click_button 'Generate'
    expect(page).to have_css('#output table.provided-attribute')
  end

  it 'viewing the Single Attribute Report – Service Providers Report' do
    click_link 'Single Attribute Report – Service Providers'

    select sp.saml_attributes.sample.name, from: 'Attribute'
    click_button 'Generate'
    expect(page).to have_css('#output table.requested-attribute')
  end

  context 'Identity Provider Attributes Report' do
    let(:button) { 'Identity Provider Attributes Report' }
    let(:report_class) { 'IdentityProviderAttributesReport' }
    let(:source) { nil }
    let(:path) { 'identity_provider_attributes_report' }
    let(:template) { 'svg.identity-provider-attributes' }

    it_behaves_like 'Subscribing to a nil class report'
  end

  context 'Single Attributes Service Provider Report' do
    let(:object) { sp.saml_attributes.sample }
    let(:target) { object.name }
    let(:list) { 'Attributes' }
    let(:button) { 'Single Attribute Report – Service Providers' }
    let(:report_class) { 'RequestedAttributeReport' }
    let(:source) { nil }
    let(:path) { 'attribute_service_providers_report' }

    it_behaves_like 'Subscribing to an automated report with target'
  end

  context 'Single Attributes Service Provider Report' do
    let(:object) { sp.saml_attributes.sample }
    let(:target) { object.name }
    let(:list) { 'Attributes' }
    let(:button) { 'Single Attribute Report – Identity Providers' }
    let(:report_class) { 'ProvidedAttributeReport' }
    let(:source) { nil }
    let(:path) { 'attribute_identity_providers_report' }

    it_behaves_like 'Subscribing to an automated report with target'
  end

  context 'Service Compatibility Report' do
    let(:target) { sp.entity_id }
    let(:object) { sp }
    let(:list) { 'Service Provider' }
    let(:button) { 'Service Compatibility Report' }
    let(:report_class) { 'ServiceCompatibilityReport' }
    let(:source) { nil }
    let(:path) { 'service_provider_compatibility_report' }

    it_behaves_like 'Subscribing to an automated report with target'
  end
end
