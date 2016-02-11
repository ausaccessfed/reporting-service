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

    context 'Subscriber Registrations' do
      given(:identifiers) do
        ['Organizations', 'Identity Providers', 'Service Providers',
         'Rapid Connect Services', 'Services']
      end

      scenario 'viewing Report' do
        click_link 'Subscriber Registrations Report'

        identifiers.each do |identifier|
          select(identifier.titleize, from: 'Subscriber Identifiers')

          click_button('Generate')

          expect(current_path)
            .to eq('/admin/reports/subscriber_registrations_report')
          expect(page).to have_css('table.subscriber-registrations')
        end
      end
    end

    context 'Federation Growth Report' do
      scenario 'viewing Report' do
        click_link 'Federation Growth Report'

        fill_in 'start', with: Time.now.utc.beginning_of_month - 1.month
        fill_in 'end', with: Time.now.utc.beginning_of_month

        click_button('Generate')

        expect(current_path)
          .to eq('/admin/reports/federation_growth_report')
        expect(page).to have_css('svg.federation-growth')
      end
    end

    context 'Daily Demand Report' do
      scenario 'viewing Report' do
        click_link 'Daily Demand Report'

        fill_in 'start', with: Time.now.utc.beginning_of_month - 1.month
        fill_in 'end', with: Time.now.utc.beginning_of_month

        click_button('Generate')

        expect(current_path)
          .to eq('/admin/reports/daily_demand_report')
        expect(page).to have_css('svg.daily-demand')
      end
    end

    context 'Federated Sessions Report' do
      scenario 'viewing Report' do
        click_link 'Federated Sessions Report'

        fill_in 'start', with: Time.now.utc.beginning_of_month - 1.month
        fill_in 'end', with: Time.now.utc.beginning_of_month

        click_button('Generate')

        expect(current_path)
          .to eq('/admin/reports/federated_sessions_report')
        expect(page).to have_css('svg.federated-sessions')
      end
    end
  end
end
