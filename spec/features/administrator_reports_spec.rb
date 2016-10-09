# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Administrator Reports' do
  given(:user) { create :subject }

  describe 'when subject is administrator' do
    %w(identity_providers
       service_providers organizations
       rapid_connect_services services).each do |identifier|
      %w(monthly quarterly yearly).each do |interval|
        given!("auto_report_#{identifier}_#{interval}".to_sym) do
          create :automated_report,
                 interval: interval,
                 target: identifier,
                 report_class: 'SubscriberRegistrationsReport'
        end
      end
    end

    background do
      attrs = create(:aaf_attributes, :from_subject, subject: user)
      RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

      entitlements = 'urn:mace:aaf.edu.au:ide:internal:aaf-admin'

      stub_ide(shared_token: user.shared_token, entitlements: [entitlements])

      visit '/auth/login'
      click_button 'Login'
      visit '/admin_reports'
    end

    scenario 'viewing the Administrator Reports Dashboard' do
      expect(current_path).to eq('/admin_reports')
      expect(page).to have_css('.list-group')
    end

    context 'Subscriber Registrations' do
      given(:identifiers) do
        %w(organizations identity_providers service_providers
           rapid_connect_services services)
      end

      scenario 'viewing Report' do
        message_01 = 'You have successfully subscribed to this report'
        message_02 = 'You have already subscribed to this report'

        click_link 'Subscriber Registrations Report'

        %w(Monthly Quarterly Yearly).each do |interval|
          identifiers.each do |identifier|
            select(identifier.titleize, from: 'Subscriber Identifiers')
            click_button('Generate')
            expect(page).to have_css('table.subscriber-registrations')
            click_button('Subscribe')
            click_link(interval)
            expect(page).to have_selector('p', text: message_01)

            select(identifier.titleize, from: 'Subscriber Identifiers')
            click_button('Generate')
            expect(page).to have_css('table.subscriber-registrations')
            click_button('Subscribe')
            click_link(interval)
            expect(page).to have_selector('p', text: message_02)

            expect(current_path)
              .to eq('/admin_reports/subscriber_registrations_report')
          end
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
          .to eq('/admin_reports/federation_growth_report')
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
          .to eq('/admin_reports/daily_demand_report')
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
          .to eq('/admin_reports/federated_sessions_report')
        expect(page).to have_css('svg.federated-sessions')
      end
    end

    context 'Identity Provider Utilization Report' do
      scenario 'viewing Report' do
        click_link 'Identity Provider Utilization Report'

        fill_in 'start', with: Time.now.utc.beginning_of_month - 1.month
        fill_in 'end', with: Time.now.utc.beginning_of_month

        click_button('Generate')

        expect(current_path)
          .to eq('/admin_reports/identity_provider_utilization_report')
        expect(page).to have_css('table.identity-provider-utilization')
      end
    end

    context 'Service Provider Utilization Report' do
      scenario 'viewing Report' do
        click_link 'Service Provider Utilization Report'

        fill_in 'start', with: Time.now.utc.beginning_of_month - 1.month
        fill_in 'end', with: Time.now.utc.beginning_of_month

        click_button('Generate')

        expect(current_path)
          .to eq('/admin_reports/service_provider_utilization_report')
        expect(page).to have_css('table.service-provider-utilization')
      end
    end
  end
end
