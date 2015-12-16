require 'rails_helper'

RSpec.describe DailyDemandReport do
  let(:type) { 'daily-demand' }
  let(:title) { 'Daily Demand' }
  let(:units) { '' }
  let(:labels) { { y: '', sessions: 'daily_demand' } }

  let!(:start) { Timecop.freeze { 10.days.ago.beginning_of_day } }
  let!(:finish) { Timecop.freeze { Time.zone.now.beginning_of_day } }

  let!(:days_count) { ((finish - start).to_i / 86_400).to_i }

  let(:identity_provider) { create :identity_provider }
  let(:service_provider) { create :service_provider }

  subject { DailyDemandReport.new(start, finish) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    (0..(86_340)).step(60).each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, value])
    end
  end

  context 'when events are sessions with response' do
    before do
      create_list :discovery_service_event, 5, :response,
                  identity_provider: identity_provider,
                  service_provider: service_provider
    end

    let(:value) { anything }

    it 'should include title, units and labels' do
      expect(report).to include(title: title, units: units, labels: labels)
    end

    it 'should not include range' do
      expect(report).not_to include(:range)
    end

    it 'sessions are response types generated within given range' do
      expect_in_range
    end
  end

  context 'when events are not responded' do
    before do
      create_list :discovery_service_event, 20,
                  service_provider: service_provider,
                  timestamp: 1.day.ago.beginning_of_day
    end

    let(:value) { 0.0 }

    it 'should not count any sessions' do
      expect_in_range
    end
  end

  context 'when events timestamps are specified manually' do
    before :example do
      [*1..5].each do |n|
        create :discovery_service_event, :response,
               identity_provider: identity_provider,
               service_provider: service_provider,
               timestamp: n.days.ago.beginning_of_day
      end
    end

    it 'should contain average number of sessions' do
      average = (5 / days_count.to_f).round(1)
      expect(data[:sessions]).to include([0, average])
    end
  end
end
