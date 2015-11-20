require 'rails_helper'

RSpec.describe RequestedAttributeReport do
  let(:type) { 'requested-attribute' }
  let(:header) { [%w(Name Status)] }

  let!(:saml_attribute) { create :saml_attribute }

  shared_examples 'a tabular report for requested attributes' do
    subject { RequestedAttributeReport.new(name) }

    let(:report) { subject.generate }

    it 'rows array should match required size' do
      expect(report[:rows][0].count).to eq(2)
    end

    it 'must contain type' do
      title = "Service Providers requesting #{name}"

      expect(report).to include(type: type, title: title, header: header)
      expect(report[:footer]).not_to be_nil
    end
  end

  context '#generate' do
    context 'required service Providers' do
      let(:name) { saml_attribute.name }

      it_behaves_like 'a tabular report for requested attributes'
    end
  end
end
