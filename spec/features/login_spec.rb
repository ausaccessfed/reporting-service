require 'rails_helper'

RSpec.feature 'Login Process' do
  include IdentityEnhancementStub

  given(:user) { create(:subject) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)
  end

  scenario 'clicking "Log In" from the welcome page' do
    visit '/'
    within('main') { click_link 'Log In' }

    expect(current_path).to eq('/auth/login')
    click_button 'Login'

    expect(current_path).to eq('/dashboard')
  end

  scenario 'viewing a protected path directly' do
    visit '/federation_reports/federation_growth'

    expect(current_path).to eq('/auth/login')
    click_button 'Login'

    expect(current_path).to eq('/federation_reports/federation_growth')
  end
end
