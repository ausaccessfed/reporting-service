require 'rails_helper'

RSpec.describe ServiceCompatibilityReport do
  let(:type) { 'service-compatibility' }
  let(:header) { [%w(Name Required Optional Compatible)] }

  let(:service_provider) { create :service_provider }

  subject { ServiceCompatibilityReport.new(service_provider.entity_id) }

  context 'a service compatibility report' do
    let(:report) { subject.generate }

    it 'must contain type, header, title' do
      name = service_provider.name
      expect(report).to include(type: type, title: name, header: header)
    end
  end
end
