require 'rails_helper'

RSpec.describe RequestedAttributeReport do
  let(:type) { 'requested-attribute' }
  let(:header) { [%w(Name Status)] }

  let(:required_attribute) { create :saml_attribute }
  let(:optional_attribute) { create :saml_attribute }
  let(:none_requested_attribute) { create :saml_attribute }

  let(:service_provider_01) { create :service_provider }
  let(:service_provider_02) { create :service_provider }

  let(:active_service_providers) do
    [service_provider_01, service_provider_02]
  end

  before do
    [service_provider_01, service_provider_02].each do |object|
      create :service_provider_saml_attribute,
             optional: false,
             saml_attribute: required_attribute,
             service_provider: object

      create :service_provider_saml_attribute,
             optional: true,
             saml_attribute: optional_attribute,
             service_provider: object
    end

    active_service_providers.each do |object|
      create :activation, federation_object: object
    end
  end

  shared_examples 'a tabular report for requested attributes' do
    subject { RequestedAttributeReport.new(attribute.name) }

    let(:report) { subject.generate }

    it 'rows array should match required size' do
      expect(report[:rows][0].count).to eq(2)
    end

    it 'must contain type' do
      title = "Service Providers requesting #{attribute.name}"

      expect(report).to include(type: type, title: title, header: header)
    end

    it 'determines attribute status for each SP' do
      status_flags = %w(required optional none)
      status_flags.delete(status)

      active_service_providers.map do |k|
        expect(report[:rows]).to include([k.name, status])

        status_flags.each do |flag|
          expect(report[:rows]).not_to include([k.name, flag])
        end
      end
    end
  end

  context '#generate' do
    context 'for required attributes' do
      let(:attribute) { required_attribute }
      let(:status) { 'required' }

      it_behaves_like 'a tabular report for requested attributes'
    end

    context 'for optional attributes' do
      let(:attribute) { optional_attribute }
      let(:status) { 'optional' }

      it_behaves_like 'a tabular report for requested attributes'
    end

    context 'for none requested attributes' do
      let(:attribute) { none_requested_attribute }
      let(:status) { 'none' }

      it_behaves_like 'a tabular report for requested attributes'
    end

    context 'report rows' do
      let(:report) { subject.generate }
      let(:inacvtive_service_provider) do
        create :service_provider
      end

      before do
        create :service_provider_saml_attribute,
               optional: false,
               saml_attribute: required_attribute,
               service_provider: inacvtive_service_provider
      end

      subject { RequestedAttributeReport.new(required_attribute.name) }

      it 'should never include inactive SPs' do
        sp_name = inacvtive_service_provider.name

        expect(report[:rows]).not_to include([sp_name, anything])
      end
    end
  end
end
