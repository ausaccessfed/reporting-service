# frozen_string_literal: true

RSpec.shared_examples 'Subscribing to an automated report with target' do
  %w[monthly quarterly yearly].each do |interval|
    let!("auto_report_#{interval}".to_sym) { create(:automated_report, interval:, target:, report_class:, source:) }
  end

  context 'subject has already subscribed to the report' do
    let!(:subscription_m) do
      create(:automated_report_subscription, subject: user, automated_report: auto_report_monthly)
    end

    let!(:subscription_q) do
      create(:automated_report_subscription, subject: user, automated_report: auto_report_quarterly)
    end

    let!(:subscription_y) do
      create(:automated_report_subscription, subject: user, automated_report: auto_report_yearly)
    end

    it 'viewing' do
      message = 'You have already subscribed to this report'

      click_link(button)
      expect(page).to have_current_path("/#{controller}/#{path}", ignore_query: true)

      %w[Monthly Quarterly Yearly].each do |interval|
        select(object.name, from: list)
        click_button('Generate')
        click_button('Subscribe')
        click_link(interval)

        expect(page).to have_current_path("/#{controller}/#{path}", ignore_query: true)
        expect(page).to have_css('p', text: message)
      end
    end
  end

  context 'subject has already subscribed to the report' do
    it 'viewing' do
      message = 'You have successfully subscribed to this report'

      click_link(button)
      expect(page).to have_current_path("/#{controller}/#{path}", ignore_query: true)

      %w[Monthly Quarterly Yearly].each do |interval|
        select(object.name, from: list)
        click_button('Generate')
        click_button('Subscribe')
        click_link(interval)

        expect(page).to have_current_path("/#{controller}/#{path}", ignore_query: true)
        expect(page).to have_css('p', text: message)
      end
    end
  end
end
