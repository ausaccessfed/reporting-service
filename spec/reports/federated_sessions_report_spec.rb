require 'rails_helper'

RSpec.describe FederatedSessionsReport do
  let(:type) { 'federated-sessions' }
  let(:title) { 'Federated Sessions' }
  let(:units) { '' }
  let(:labels) { { y: '', sessions: 'Rate/m' } }

  let!(:start) { 11.days.ago.beginning_of_day }
  let!(:finish) { Time.zone.now }
  let(:steps) { 5 }
  let!(:range) { { start: start.xmlschema, end: finish.xmlschema } }
  let(:scope_range) do
    (0..(finish - start).to_i).step(steps.minutes)
  end

  subject { FederatedSessionsReport.new(start, finish, steps) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    scope_range.each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, value])
    end
  end

  context 'when objects are sessions' do
    before do
      create_list :discovery_service_event, 20, :response
    end

    let(:value) { anything }

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

    let(:value) { 0 }

    it 'should not count any sessions' do
      expect_in_range
    end
  end

  context 'when objects timestamp is specified manually' do
    context '2 days ago' do
      before :example do
        create_list :discovery_service_event, 10, :response,
                    timestamp: 2.days.ago.beginning_of_day

        create_list :discovery_service_event, 20, :response,
                    timestamp: 5.days.ago.beginning_of_day
      end

      it 'should contain 2.0 objects/m during first 5 minutes of 2 days ago' do
        time = 2.days.ago.beginning_of_day - start
        expect(data[:sessions]).to include([time, 2.0])
      end

      it 'should contain 4.0 objects/m during first 5 minutes of 5 days ago' do
        time = 5.days.ago.beginning_of_day - start
        expect(data[:sessions]).to include([time, 4.0])
      end
    end
  end
end
