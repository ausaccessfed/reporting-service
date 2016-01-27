require 'rails_helper'

RSpec.describe AdministratorReportsController, type: :routing do
  describe 'GET /admin/reports' do
    subject { { get: 'admin/reports' } }
    it { is_expected.to route_to('administrator_reports#index') }
  end
end
