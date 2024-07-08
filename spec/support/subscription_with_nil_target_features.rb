# frozen_string_literal: true

RSpec.shared_examples 'Subscribing to a nil class report' do
  %w[monthly quarterly yearly].each do |interval|
    given!("auto_report_#{interval}".to_sym) { create(:automated_report, interval:, report_class:, source:) }
  end

  context 'subject has already subscribed to the report' do
    given!(:subscription_m) do
      create(:automated_report_subscription, subject: user, automated_report: auto_report_monthly)
    end

    given!(:subscription_q) do
      create(:automated_report_subscription, subject: user, automated_report: auto_report_quarterly)
    end

    given!(:subscription_y) do
      create(:automated_report_subscription, subject: user, automated_report: auto_report_yearly)
    end

    scenario 'viewing' do
      message = 'You have already subscribed to this report'

      click_link_or_button(button)
      expect(page).to have_current_path("/#{controller}/#{path}", ignore_query: true)
      expect(page).to have_css(template)

      %w[Monthly Quarterly Yearly].each do |interval|
        click_link_or_button('Subscribe')
        click_link_or_button(interval)
        expect(page).to have_current_path("/#{controller}/#{path}", ignore_query: true)
        expect(page).to have_css('p', text: message)
      end
    end
  end

  context 'subject has already subscribed to the report' do
    scenario 'viewing' do
      message = 'You have successfully subscribed to this report'

      click_link_or_button(button)
      expect(page).to have_current_path("/#{controller}/#{path}", ignore_query: true)
      expect(page).to have_css(template)

      %w[Monthly Quarterly Yearly].each do |interval|
        click_link_or_button('Subscribe')
        click_link_or_button(interval)
        expect(page).to have_current_path("/#{controller}/#{path}", ignore_query: true)
        expect(page).to have_css('p', text: message)
      end
    end
  end
end
