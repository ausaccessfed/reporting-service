# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'automated report' do
  given(:user) { create :subject }
  given(:user_02) { create :subject }
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

  given!(:subscription_1) do
    create :automated_report_subscription,
           automated_report: auto_report_idp,
           subject: user
  end

  given!(:subscription_2) do
    create :automated_report_subscription,
           automated_report: auto_report_org,
           subject: user
  end

  given!(:subscription_3) do
    create :automated_report_subscription,
           automated_report: auto_report_saml,
           subject: user
  end

  describe 'when user has subscriptions' do
    background do
      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      stub_ide(shared_token: user.shared_token)

      visit '/auth/login'
      click_button 'Login'
      visit '/subscriber_reports'
      click_link 'Subscriptions'
    end

    scenario 'viewing automated_reports#index' do
      expect(current_path).to eq('/automated_reports')

      expect(page).to have_text(idp.name[0..50])
      expect(page).to have_text('Organizations')
      expect(page).to have_text(saml.name[0..50])
    end

    scenario 'should unsubscribe and redirect to index' do
      within 'table' do
        first('button', 'Unsubscribe').click
        click_link('Confirm Unsubscribe')
      end

      expect(current_path).to eq('/automated_reports')

      message = 'You have unsubscribed from an automated report'

      expect(page).to have_selector('p', text: message)
    end
  end

  describe 'when user has no subscriptions yet' do
    background do
      attrs = create(:aaf_attributes, :from_subject, subject: user_02)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      stub_ide(shared_token: user_02.shared_token)

      visit '/auth/login'
      click_button 'Login'
      visit '/subscriber_reports'
      click_link 'Subscriptions'
    end

    scenario 'should unsubscribe and redirect to index' do
      expect(current_path).to eq('/automated_reports')

      message = 'You can subscribe to an automated report by '\
                'clicking on the `Subscribe` button in report page '\
                'and choosing a report interval'

      expect(page).to have_selector('p', text: message)
    end
  end
end
