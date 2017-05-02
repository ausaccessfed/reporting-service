# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Subscriber Reports' do
  given(:user) { create :subject }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    stub_ide(shared_token: user.shared_token)

    visit '/auth/login'
    click_button 'Login'
    visit '/subscriber_reports'
  end

  scenario 'viewing the Subscriber Reports #index' do
    expect(current_path).to eq('/subscriber_reports')
  end
end
