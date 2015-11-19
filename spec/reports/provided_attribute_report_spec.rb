require 'rails_helper'

RSpec.describe ProvidedAttributeReport do
  let(:type) { 'provided-attribute-report' }
  let(:header) { [%w(Name Supported)] }

  let(:attribute) { create :saml_attribute }
  let(:title) { attribute.name }

  subject { ProvidedAttributeReport.new(title) }

  context '#generate' do
    let(:report) { subject.generate }

    it 'produces title, header and type' do
      expect(report).to include(header: header,
                                type: type, title: title)
    end
  end
end
