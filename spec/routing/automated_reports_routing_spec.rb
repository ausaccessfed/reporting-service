require 'rails_helper'

RSpec.describe AutomatedReportsController, type: :controller do
  describe 'route to /automated_reports/index' do
    subject { { get: '/automated_reports' } }
    it { is_expected.to route_to 'automated_reports#index' }
  end

  describe 'route to /automated_reports/unsubscribe' do
    subject { { delete: '/automated_reports' } }
    it { is_expected.to route_to 'automated_reports#unsubscribe' }
  end
end
