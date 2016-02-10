require 'rails_helper'

RSpec.feature 'automated report instances' do
  include IdentityEnhancementStub
  given(:user) { create :subject }
  given(:organization) { create :organization }
  given(:idp) { create :identity_provider }

  given!(:auto_report) do
    create :automated_report,
           report_class: 'IdentityProviderSessionsReport',
           target: idp.entity_id
  end

  given!(:subscription) do
    create :automated_report_subscription,
           automated_report: auto_report,
           subject: user
  end

  background do
    create :activation, federation_object: idp
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)

    visit '/auth/login'
    click_button 'Login'
    visit "/automated_report_instances/#{subscription.identifier}"
  end

  scenario 'viewing automated_report_instances#show' do
    identifier = subscription.identifier
    expect(current_path).to eq("/automated_report_instances/#{identifier}")
  end
end
