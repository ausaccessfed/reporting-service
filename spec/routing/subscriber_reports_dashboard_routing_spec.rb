# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SubscriberReportsDashboardController do
  describe 'get /subscriber_reports' do
    subject { { get: '/subscriber_reports' } }
    it { is_expected.to route_to 'subscriber_reports_dashboard#index' }
  end
end
