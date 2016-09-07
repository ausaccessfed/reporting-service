# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AutomatedReportsController, type: :routing do
  describe 'route to /automated_reports/index' do
    subject { { get: '/automated_reports' } }
    it { is_expected.to route_to 'automated_reports#index' }
  end

  describe 'route to /automated_reports/unsubscribe' do
    param = { identifier: 'identifier' }
    subject { { delete: '/automated_reports/identifier' } }

    it { is_expected.to route_to 'automated_reports#destroy', param }
  end

  describe 'route to /automated_reports/subscribe' do
    subject { { post: '/automated_reports' } }

    it { is_expected.to route_to 'automated_reports#subscribe' }
  end
end
