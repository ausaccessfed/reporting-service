require 'rails_helper'

RSpec.feature 'Administrator Reports' do
  include IdentityEnhancementStub

  given(:user) { create :subject }

  describe 'when subject is administrator' do
    background do
      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      entitlements = 'urn:mace:aaf.edu.au:ide:internal:aaf-admin'

      stub_ide(shared_token: user.shared_token, entitlements: [entitlements])

      visit '/auth/login'
      click_button 'Login'
      visit '/admin/reports'
    end

    scenario 'viewing the Administrator Reports Dashboard' do
      expect(current_path).to eq('/admin/reports')
      expect(page).to have_css('.list-group')
    end
  end
end
