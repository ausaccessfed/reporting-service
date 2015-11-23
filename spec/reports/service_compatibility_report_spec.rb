require 'rails_helper'

RSpec.describe ServiceCompatibilityReport do
  let(:type) { 'service-compatibility' }
  let(:header) { [%w(Name Required Optional Compatible)] }

  let(:service_provider) { create :service_provider }
  let(:core_attr_set_01) do
    create_list :saml_attribute, 5
  end

  let(:idp_01) do
    create :identity_provider,
           saml_attributes: core_attr_set_01
  end

  before do
    create :activation, federation_object: idp_01
  end

  subject { ServiceCompatibilityReport.new(service_provider.entity_id) }

  context 'a service compatibility report' do
    let(:report) { subject.generate }

    it 'must contain type, header, title' do
      name = service_provider.name
      expect(report).to include(type: type, title: name, header: header)
    end

    it '#rows include active IdPs name' do
      name = idp_01.name
      expect(report[:rows]).to include([name, anything, anything, anything])
    end
  end
end
