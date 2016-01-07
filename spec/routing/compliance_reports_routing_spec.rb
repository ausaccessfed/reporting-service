require 'rails_helper'

RSpec.describe ComplianceReportsController, type: :routing do
  describe 'get /compliance_reports/service_provider/compatibility_report' do
    let(:action) { 'compliance_reports#service_provider_compatibility_report' }

    subject do
      { get: '/compliance_reports/service_provider/compatibility_report' }
    end

    it { is_expected.to route_to(action) }
  end

  describe 'post /compliance_reports/service_provider/compatibility_report' do
    let(:action) { 'compliance_reports#service_provider_compatibility_report' }

    subject do
      { post: '/compliance_reports/service_provider/compatibility_report' }
    end

    it { is_expected.to route_to(action) }
  end

  describe 'get /compliance_reports/identity_provider/attributes_report' do
    let(:action) { 'compliance_reports#identity_provider_attributes_report' }

    subject do
      { get: '/compliance_reports/identity_provider/attributes_report' }
    end

    it { is_expected.to route_to(action) }
  end
end
