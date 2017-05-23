# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyDemandReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'daily-demand' }
  let(:title) { 'Daily Demand' }
  let(:units) { '' }
  let(:labels) { { y: 'Sessions / hour (average)', sessions: 'Sessions' } }

  let(:start) { 10.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:days_count) { ((finish - start).to_i / 86_400).to_i }

  let(:range) do
    { start: start.strftime('%FT%H:%M:%S%z'),
      end: finish.strftime('%FT%H:%M:%S%z') }
  end

  let(:identity_provider) { create :identity_provider }
  let(:service_provider) { create :service_provider }

  subject { DailyDemandReport.new(start, finish) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    (0..86_340).step(300).each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, value])
    end
  end

  context 'when events are sessions with response' do
    before do
      create_list :discovery_service_event, 5, :response,
                  selected_idp: identity_provider.entity_id,
                  initiating_sp: service_provider.entity_id
    end

    let(:value) { anything }

    it 'should include title, units and labels' do
      expect(report).to include(title: title, units: units,
                                labels: labels, range: range)
    end

    it 'sessions are response types generated within given range' do
      expect_in_range
    end
  end

  context 'when events are not responded' do
    before do
      create_list :discovery_service_event, 20,
                  initiating_sp: service_provider.entity_id,
                  timestamp: 1.day.ago.beginning_of_day
    end

    let(:value) { 0.00 }

    it 'should not count any sessions' do
      expect_in_range
    end
  end

  context 'when events timestamps are specified manually' do
    before :example do
      [*1..5].each do |n|
        create :discovery_service_event, :response,
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider.entity_id,
               timestamp: n.days.ago.beginning_of_day

        create :discovery_service_event, :response,
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider.entity_id,
               timestamp: n.days.ago.beginning_of_day + 10.minutes

        create :discovery_service_event, :response,
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider.entity_id,
               timestamp: n.days.ago.end_of_day
      end
    end

    it 'average at point 0 should be 0.5 for 5 sessions in 10 days' do
      expect(data[:sessions]).to include([0, 0.45])
    end

    it 'average should be 0.0 when no sessions available at point 300' do
      expect(data[:sessions]).to include([300, 0.00])
    end

    it 'average at point 600 should be 0.5 for 5 sessions in 10 days' do
      expect(data[:sessions]).to include([600, 0.45])
    end

    it 'average at point 86_340 should be 0.5 for 5 sessions in 10 days' do
      expect(data[:sessions]).to include([86_100, 0.45])
    end
  end
end
