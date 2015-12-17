require 'rails_helper'

RSpec.describe IdentityProviderSessionsReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'identity-provider-sessions' }
  let(:title) { 'Identity Provider Sessions' }

  let(:labels) { { y: '', sessions: 'sessions' } }
  let(:units) { '' }

  let!(:start) { 10.days.ago.beginning_of_day }
  let!(:finish) { 1.day.ago.end_of_day }

  let!(:range) { { start: start.xmlschema, end: finish.xmlschema } }

  let(:identity_provider) { create :identity_provider }
  let(:service_provider) { create :service_provider }

  subject { IdentityProviderSessionsReport.new(start, finish) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  context 'when events are sessions with response' do
    before do
      create_list :discovery_service_event, 20, :response,
                  identity_provider: identity_provider,
                  service_provider: service_provider
    end

    it 'should include title, units, labels and range' do
      expect(report).to include(title: title, units: units,
                                labels: labels, range: range)
    end
  end
end
