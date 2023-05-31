# frozen_string_literal: true

RSpec.shared_examples 'Subscribing to an automated report with target' do
  %w[monthly quarterly yearly].each do |interval|
    given!("auto_report_#{interval}".to_sym) do
      create :automated_report,
             interval:,
             target:,
             report_class:,
             source:
    end
  end

  context 'subject has already subscribed to the report' do
    given!(:subscription_m) do
      create :automated_report_subscription,
             subject: user, automated_report: auto_report_monthly
    end

    given!(:subscription_q) do
      create :automated_report_subscription,
             subject: user, automated_report: auto_report_quarterly
    end

    given!(:subscription_y) do
      create :automated_report_subscription,
             subject: user, automated_report: auto_report_yearly
    end

    scenario 'viewing' do
      message = 'You have already subscribed to this report'

      click_link(button)
      expect(current_path).to eq("/#{controller}/#{path}")

      %w[Monthly Quarterly Yearly].each do |interval|
        select(object.name, from: list)
        click_button('Generate')
        click_button('Subscribe')
        click_link(interval)

        expect(current_path).to eq("/#{controller}/#{path}")
        expect(page).to have_selector('p', text: message)
      end
    end
  end

  context 'subject has already subscribed to the report' do
    scenario 'viewing' do
      message = 'You have successfully subscribed to this report'

      click_link(button)
      expect(current_path).to eq("/#{controller}/#{path}")

      %w[Monthly Quarterly Yearly].each do |interval|
        select(object.name, from: list)
        click_button('Generate')
        click_button('Subscribe')
        click_link(interval)

        expect(current_path).to eq("/#{controller}/#{path}")
        expect(page).to have_selector('p', text: message)
      end
    end
  end
end
