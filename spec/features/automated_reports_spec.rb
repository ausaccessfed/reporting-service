# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'automated report' do
  let(:user) { create(:subject) }
  let(:user_02) { create(:subject) }
  let(:idp) { create(:identity_provider) }
  let(:saml) { create(:saml_attribute) }

  let!(:auto_report_idp) do
    create(
      :automated_report,
      report_class: 'IdentityProviderSessionsReport',
      source: data_source,
      target: idp.entity_id
    )
  end

  let(:auto_report_org) do
    create(:automated_report, report_class: 'SubscriberRegistrationsReport', target: 'organizations')
  end

  let(:auto_report_saml) { create(:automated_report, report_class: 'RequestedAttributeReport', target: saml.name) }

  let!(:subscription_1) { create(:automated_report_subscription, automated_report: auto_report_idp, subject: user) }

  let!(:subscription_2) { create(:automated_report_subscription, automated_report: auto_report_org, subject: user) }

  let!(:subscription_3) { create(:automated_report_subscription, automated_report: auto_report_saml, subject: user) }

  shared_examples 'automated reports tests' do
    describe 'when user has subscriptions' do
      before do
        attrs = create(:aaf_attributes, :from_subject, subject: user)
        RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

        visit '/auth/login'
        click_button 'Login'
        visit '/subscriber_reports'
        click_link 'Subscriptions'
      end

      it 'viewing automated_reports#index' do
        expect(page).to have_current_path('/automated_reports', ignore_query: true)

        expect(page).to have_text(idp.name[0..50])
        expect(page).to have_text('Organizations')
        expect(page).to have_text(saml.name[0..50])
        expect(page).to have_text(data_source_name)
      end

      it 'unsubscribes and redirect to index' do
        within 'table' do
          first('button', text: 'Unsubscribe').click
          click_link('Confirm Unsubscribe')
        end

        expect(page).to have_current_path('/automated_reports', ignore_query: true)

        message = 'You have unsubscribed from an automated report'

        expect(page).to have_css('p', text: message)
      end
    end

    describe 'when user has no subscriptions yet' do
      before do
        attrs = create(:aaf_attributes, :from_subject, subject: user_02)
        RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

        visit '/auth/login'
        click_button 'Login'
        visit '/subscriber_reports'
        click_link 'Subscriptions'
      end

      it 'unsubscribes and redirect to index' do
        expect(page).to have_current_path('/automated_reports', ignore_query: true)

        message =
          'You can subscribe to an automated report by ' \
            'clicking on the `Subscribe` button in report page ' \
            'and choosing a report interval'

        expect(page).to have_css('p', text: message)
      end
    end
  end

  context 'session source is DS' do
    let(:data_source) { 'DS' }
    let(:data_source_name) { 'Discovery Service' }

    it_behaves_like 'automated reports tests'
  end

  context 'session source is IdP' do
    let(:data_source) { 'IdP' }
    let(:data_source_name) { 'IdP Event Log' }

    it_behaves_like 'automated reports tests'
  end
end
