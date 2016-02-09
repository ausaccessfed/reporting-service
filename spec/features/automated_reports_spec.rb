require 'rails_helper'

RSpec.feature 'automated report' do
  include IdentityEnhancementStub
  given(:user) { create :subject }
  given(:organization) { create :organization }
  given(:idp) { create :identity_provider }
  given(:saml) { create :saml_attribute }

  given!(:auto_report_idp) do
    create :automated_report,
           report_class: 'IdentityProviderSessionsReport',
           target: idp.entity_id
  end

  given(:auto_report_org) do
    create :automated_report,
           report_class: 'SubscriberRegistrationsReport',
           target: 'organizations'
  end

  given(:auto_report_saml) do
    create :automated_report,
           report_class: 'RequestedAttributeReport',
           target: saml.name
  end

  background do
    create :activation, federation_object: idp

    create :automated_report_subscription,
           automated_report: auto_report_idp,
           subject: user

    create :automated_report_subscription,
           automated_report: auto_report_org,
           subject: user

    create :automated_report_subscription,
           automated_report: auto_report_saml,
           subject: user

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

    expect(page).to have_text(idp.name)
    expect(page).to have_text('Organizations')
    expect(page).to have_text(saml.name)
  end
end
