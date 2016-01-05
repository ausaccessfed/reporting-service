require 'rails_helper'

RSpec.describe FederationReportsController, type: :routing do
  describe 'GET /federation_reports/federation_growth' do
    subject { { get: '/federation_reports/federation_growth' } }
    it { is_expected.to route_to('federation_reports#federation_growth') }
  end
end
