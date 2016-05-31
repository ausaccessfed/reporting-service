# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AutomatedReportInstancesController, type: :controller do
  describe 'route to /automated_report_instances/show' do
    subject { { get: '/automated_report/identifier' } }
    prefix = 'automated_report_instances#show'

    it { is_expected.to route_to prefix, identifier: 'identifier' }
  end
end
