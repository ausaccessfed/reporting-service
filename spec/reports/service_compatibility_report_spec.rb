require 'rails_helper'

RSpec.describe ServiceCompatibilityReport do
  let(:type) { 'service-compatibility' }
  let(:header) { [%w(Name Required Optional Compatible)] }
  let(:title) { 'sp-name' }

  subject { ServiceCompatibilityReport.new(title) }

  context 'a service compatibility report' do
    let(:report) { subject.generate }

    it 'must contain type, header, title' do
      expect(report).to include(type: type, title: title, header: header)
    end
  end
end
