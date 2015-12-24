require 'rails_helper'

RSpec.feature 'Login Process' do
  include IdentityEnhancementStub

  given(:user) { create(:subject) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)
  end

  feature 'requesting /auth/login path' do
    background do
      visit '/auth/login'
      click_button 'Login'
    end

    scenario 'viewing the Dashboard' do
      expect(current_path).to eq('/dashboard')

      click_link('Federation Growth Report')
    end
  end

  feature 'requesting /public_reports/federation_growth path' do
    background do
      visit '/public_reports/federation_growth'
      click_button 'Login'
    end

    scenario 'viewing the Federation Growth Report directly' do
      expect(current_path).to eq('/public_reports/federation_growth')
    end
  end
end
