require 'rails_helper'

RSpec.describe ComplianceReportsController, type: :routing do
  let(:controller) { 'compliance_reports' }

  shared_examples 'get request' do
    subject do
      { get: controller + path }
    end

    it { is_expected.to route_to(controller + action) }
  end

  shared_examples 'post request' do
    subject do
      { post: controller + path }
    end

    it { is_expected.to route_to(controller + action) }
  end

  describe 'get /service_provider/compatibility_report' do
    let(:action) { '#service_provider_compatibility_report' }
    let(:path) { '/service_provider/compatibility_report' }
    it_behaves_like 'get request'
  end

  describe 'get /identity_provider/attributes_report' do
    let(:action) { '#identity_provider_attributes_report' }
    let(:path) { '/identity_provider/attributes_report' }
    it_behaves_like 'get request'
  end

  describe 'post /service_provider/compatibility_report' do
    let(:action) { '#service_provider_compatibility_report' }
    let(:path) { '/service_provider/compatibility_report' }
    it_behaves_like 'post request'
  end
end
