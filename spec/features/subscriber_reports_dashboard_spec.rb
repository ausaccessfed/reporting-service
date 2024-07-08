# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Subscriber Reports' do
  given(:user) { create(:subject) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_link_or_button 'Login'
    visit '/subscriber_reports'
  end

  scenario 'viewing the Subscriber Reports #index' do
    expect(page).to have_current_path('/subscriber_reports', ignore_query: true)
  end
end
