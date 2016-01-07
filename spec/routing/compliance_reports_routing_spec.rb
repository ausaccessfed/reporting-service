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

  describe 'post & get on /service_provider/compatibility_report' do
    let(:action) { '#service_provider_compatibility_report' }
    let(:path) { '/service_provider/compatibility_report' }

    it_behaves_like 'post request'
    it_behaves_like 'get request'
  end

  describe 'get on /identity_provider/attributes_report' do
    let(:action) { '#identity_provider_attributes_report' }
    let(:path) { '/identity_provider/attributes_report' }

    it_behaves_like 'get request'
  end

  describe 'post & get on /attribute/identity_providers' do
    let(:action) { '#attribute_identity_providers' }
    let(:path) { '/attribute/identity_providers' }

    it_behaves_like 'post request'
    it_behaves_like 'get request'
  end
end
