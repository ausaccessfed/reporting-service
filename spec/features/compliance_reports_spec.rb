require 'rails_helper'

RSpec.feature 'Compliance Reports' do
  include IdentityEnhancementStub

  given(:user) { create(:subject) }
  given!(:sp) { create(:service_provider) }
  given!(:activation) { create(:activation, federation_object: sp) }
  given!(:attribute) { create(:saml_attribute) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)

    visit '/auth/login'
    click_button 'Login'
  end

  scenario 'viewing the Service Compatibility Report' do
    click_link 'Service Compatibility Report'

    select sp.name, from: 'Service Provider'
    click_button 'Generate'

    expect(page).to have_css('#output table.service-compatibility')
  end

  scenario 'viewing the Identity Provider Attributes Report' do
    click_link 'Identity Provider Attributes'

    expect(page).to have_css('#output table.identity-provider-attributes')
  end

  scenario 'viewing the Single Attribute Report – Identity Providers Report',
           focus: true do
    click_link 'Single Attribute Report – Identity Providers'

    select attribute.name, from: 'Attribute'
    click_button 'Generate'
    expect(page).to have_css('#output table.provided-attribute')
  end
end
