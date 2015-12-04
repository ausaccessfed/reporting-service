require 'rails_helper'

RSpec.describe FederatedSessionsReport do
  let(:type) { 'federated-sessions' }
  let(:title) { 'Federated Sessions' }
  let(:units) { '' }
  let(:labels) { { y: '', sessions: 'Rate/m' } }

  let(:start) { Time.zone.now.beginning_of_day }
  let(:finish) { (start + 2.hour) }
  let(:steps) { 10.5 }
  let!(:range) { { start: start.xmlschema, end: finish.xmlschema } }
  let(:scope_range) { (0..(finish.to_i - start.to_i)).step(steps) }

  before :context do
    create_list :discovery_service_event, 100
  end

  subject { FederatedSessionsReport.new(start, finish, steps) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    scope_range.each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, anything])
    end
  end

  context 'a federated sessions report' do
    it 'includes title' do
      expect(report).to include(title: title, units: units,
                                labels: labels, range: range)
    end

    it 'report should be generated within a range' do
      scope_range
    end
  end
end
