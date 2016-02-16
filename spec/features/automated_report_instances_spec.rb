require 'rails_helper'

RSpec.feature 'automated report instances' do
  include IdentityEnhancementStub
  given(:user) { create :subject }
  given(:organization) { create :organization }

  given!(:auto_report) do
    create :automated_report,
           report_class: 'DailyDemandReport'
  end

  given(:subscription) do
    create :automated_report_subscription,
           automated_report: auto_report,
           subject: user
  end

  given!(:auto_report_intance) do
    create :automated_report_instance,
           automated_report: auto_report
  end

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)

    visit '/auth/login'
    click_button 'Login'
    visit "/automated_reports/#{auto_report_intance.identifier}"
  end

  scenario 'viewing automated_report_instances#show' do
    identifier = auto_report_intance.identifier

    expect(current_path).to eq("/automated_reports/#{identifier}")
    expect(page).to have_css('#output svg.daily-demand')
  end
end
