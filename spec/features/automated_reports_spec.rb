require 'rails_helper'

RSpec.feature 'automated report' do
  include IdentityEnhancementStub

  given(:user) { create :subject }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)

    visit '/auth/login'
    click_button 'Login'
    visit '/automated_reports'
  end

  scenario 'viewing automated_reports#index' do
    expect(current_path).to eq('/automated_reports')

    visit '/subscriber_reports'
    click_link 'Automated Reports'
  end
end
