require 'rails_helper'

RSpec.describe FederatedSessionsReport do
  let(:type) { 'federated-sessions' }
  let(:title) { 'Federated Sessions' }
  let(:units) { '' }
  let(:labels) { { y: '', sessions: 'Rate/m' } }

  let(:start) { Time.zone.now.beginning_of_day }
  let(:finish) { (start + 2.hour) }
  let!(:range) { { start: start.xmlschema, end: finish.xmlschema } }

  before :context do
    create_list :discovery_service_event, 100
  end

  subject { FederatedSessionsReport.new(start, finish) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  context 'a federated sessions report' do
    it 'includes title' do
      expect(report).to include(title: title, units: units,
                                labels: labels, range: range)
    end
  end
end
