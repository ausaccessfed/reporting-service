# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login Process' do
  let(:user) { create(:subject) }

  before do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
  end

  it 'clicking "Log In" from the welcome page' do
    visit '/'
    within('main') { click_link 'Log In' }

    expect(page).to have_current_path('/auth/login', ignore_query: true)
    click_button 'Login'

    expect(page).to have_current_path('/dashboard', ignore_query: true)
  end

  it 'viewing a protected path directly' do
    visit '/federation_reports/federation_growth_report'

    expect(page).to have_current_path('/auth/login', ignore_query: true)
    click_button 'Login'

    expect(page).to have_current_path('/federation_reports/federation_growth_report', ignore_query: true)
  end
end
