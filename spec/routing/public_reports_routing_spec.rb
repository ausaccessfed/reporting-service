require 'rails_helper'

RSpec.describe PublicReportsController, type: :routing do
  describe 'GET /public_reports/federation_growth' do
    subject { { get: '/public_reports/federation_growth' } }
    it { is_expected.to route_to('public_reports#federation_growth') }
  end
end
