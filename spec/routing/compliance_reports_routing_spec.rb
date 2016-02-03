require 'rails_helper'

RSpec.describe ComplianceReportsController, type: :routing do
  shared_examples 'get request' do
    subject do
      { get: "compliance_reports#{path}" }
    end

    it { is_expected.to route_to("compliance_reports#{action}") }
  end

  shared_examples 'post request' do
    subject do
      { post: "compliance_reports#{path}" }
    end

    it { is_expected.to route_to("compliance_reports#{action}") }
  end

  describe 'get on /identity_provider/attributes_report' do
    let(:action) { '#identity_provider_attributes_report' }
    let(:path) { '/identity_provider/attributes_report' }

    it_behaves_like 'get request'
  end

  describe 'get on /service_provider/compatibility_report' do
    let(:action) { '#service_provider_compatibility_report' }
    let(:path) { '/service_provider/compatibility_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /service_provider/compatibility_report' do
    let(:action) { '#service_provider_compatibility_report' }
    let(:path) { '/service_provider/compatibility_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /attribute/identity_providers_report' do
    let(:action) { '#attribute_identity_providers_report' }
    let(:path) { '/attribute/identity_providers_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /attribute/identity_providers_report' do
    let(:action) { '#attribute_identity_providers_report' }
    let(:path) { '/attribute/identity_providers_report' }

    it_behaves_like 'post request'
  end

  describe 'get on /attribute/service_providers_report' do
    let(:action) { '#attribute_service_providers_report' }
    let(:path) { '/attribute/service_providers_report' }

    it_behaves_like 'get request'
  end

  describe 'post on /attribute/service_providers_report' do
    let(:action) { '#attribute_service_providers_report' }
    let(:path) { '/attribute/service_providers_report' }

    it_behaves_like 'post request'
  end
end
