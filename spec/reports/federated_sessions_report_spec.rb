require 'rails_helper'

RSpec.describe FederatedSessionsReport do
  let(:type) { 'federated-sessions' }
  let(:title) { 'Federated Sessions' }
  let(:units) { '' }
  let(:labels) { { y: '', sessions: 'Rate/m' } }

  let(:start) { 2.days.ago.beginning_of_day }
  let(:finish) { 1.day.ago.beginning_of_day }
  let(:steps) { 10 }
  let!(:range) { { start: start.xmlschema, end: finish.xmlschema } }
  let(:scope_range) do
    ((steps.minutes.to_i)..(finish - start).to_i).step(steps.minutes)
  end

  subject { FederatedSessionsReport.new(start, finish, steps) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    scope_range.each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, anything])
    end
  end

  context 'when objects are sessions' do
    before :context do
      create_list :discovery_service_event, 20, :response,
                  timestamp: 1.day.ago.beginning_of_day
    end

    it 'includes title' do
      expect(report).to include(title: title, units: units,
                                labels: labels, range: range)
    end

    it 'sessions are response types generated within given range' do
      expect_in_range
    end
  end

  context 'when sessions are not responded' do
    before do
      create_list :discovery_service_event, 20,
                  timestamp: 1.day.ago.beginning_of_day
    end

    it 'should not count any sessions' do
      expect_in_range
    end
  end
end
