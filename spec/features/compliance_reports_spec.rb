require 'rails_helper'

RSpec.feature 'Compliance Reports' do
  include IdentityEnhancementStub

  given(:user) { create(:subject) }
  given!(:sp) { create(:service_provider) }
  given!(:activation) { create(:activation, federation_object: sp) }

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
end
