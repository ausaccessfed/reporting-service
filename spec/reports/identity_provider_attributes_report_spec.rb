require 'rails_helper'

RSpec.describe IdentityProviderAttributesReport do
  let(:type) { 'identity-provider-attributes' }
  let(:header) { [['Name', 'Core Attributes', 'Optional Attributes']] }
  let(:title) { 'Identity Provider Attributes' }

  subject { IdentityProviderAttributesReport.new }

  context 'a tabular repot which lists IdPs attributes' do
    it 'rows data is an array' do
      expect(subject.rows).to be_a(Array)
    end

    it 'includes report :type, :header, :footer' do
      expect(subject.generate).to include(type: type,
                                          title: title, header: header)
    end
  end
end
