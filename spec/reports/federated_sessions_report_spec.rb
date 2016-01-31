require 'rails_helper'

RSpec.describe FederatedSessionsReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'federated-sessions' }
  let(:title) { 'Federated Sessions' }
  let(:units) { '' }
  let(:labels) { { y: '', sessions: 'Rate/h' } }

  let!(:start) { 10.days.ago.beginning_of_day }
  let!(:finish) { 1.day.ago.end_of_day }

  let(:steps) { 5 }
  let!(:range) { { start: start.xmlschema, end: finish.xmlschema } }
  let(:scope_range) do
    (0..(finish - start).to_i).step(steps.hours.to_i)
  end

  let(:identity_provider) { create :identity_provider }
  let(:service_provider) { create :service_provider }

  subject { FederatedSessionsReport.new(start, finish, steps) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    scope_range.each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, value])
    end
  end

  context 'when events are sessions with response' do
    before do
      create_list :discovery_service_event, 20, :response,
                  selected_idp: identity_provider.entity_id,
                  initiating_sp: service_provider.entity_id
    end

    let(:value) { anything }

    it 'should include title, units, labels and range' do
      expect(report).to include(title: title, units: units,
                                labels: labels, range: range)
    end

    it 'sessions should be generated within given range' do
      expect_in_range
    end
  end

  context 'when events are not responded' do
    before do
      create_list :discovery_service_event, 20,
                  initiating_sp: service_provider.entity_id,
                  timestamp: 1.day.ago.beginning_of_day
    end

    let(:value) { 0.0 }

    it 'should not count any sessions' do
      expect_in_range
    end
  end

  context 'when events timestamps are specified manually' do
    before :example do
      create_list :discovery_service_event, 5, :response,
                  selected_idp: identity_provider.entity_id,
                  initiating_sp: service_provider.entity_id,
                  timestamp: start

      create_list :discovery_service_event, 10, :response,
                  selected_idp: identity_provider.entity_id,
                  initiating_sp: service_provider.entity_id,
                  timestamp: 2.days.ago.beginning_of_day

      create_list :discovery_service_event, 9, :response,
                  selected_idp: identity_provider.entity_id,
                  initiating_sp: service_provider.entity_id,
                  timestamp: finish
    end

    it 'average should be 1.0 for 5 sessions during first 5 hours' do
      time = [*scope_range].first
      expect(data[:sessions]).to include([time, 1.0])
    end

    it 'should contain 2.0 sessions/h during first 5 hours of 2 days ago' do
      expect(data[:sessions]).to include([684_000, 2.0])
    end

    it 'average should be 0.0 for no sessions during 2nd last 5 hours' do
      time = [*scope_range][-2]
      expect(data[:sessions]).to include([time, 0.0])
    end

    it 'average should be 1.8 for 9 sessions during last 5 hours' do
      time = [*scope_range].last
      expect(data[:sessions]).to include([time, 1.8])
    end
  end
end
