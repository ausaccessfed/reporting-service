require 'rails_helper'

RSpec.describe AutomatedReportInstancesController, type: :controller do
  describe 'route to /automated_report_instances/show' do
    subject { { get: '/automated_reports/report_id' } }
    prefix = 'automated_report_instances#show'

    it { is_expected.to route_to prefix, report_id: 'report_id' }
  end
end
