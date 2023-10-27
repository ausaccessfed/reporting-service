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

  let(:range) { { start: start.strftime('%FT%H:%M:%S%z'), end: finish.strftime('%FT%H:%M:%S%z') } }

  let(:identity_provider) { create :identity_provider }
  let(:service_provider) { create :service_provider }

  subject { DailyDemandReport.new(start, finish, source) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    (0..86_340).step(300).each_with_index { |t, index| expect(data[:sessions][index]).to match_array([t, value]) }
  end

  shared_examples 'a report procesing events from the selected source' do
    before { 5.times { create_event } }
    let(:value) { anything }

    it 'should include title, units and labels' do
      output_title = "#{title} (#{source_name})"
      expect(report).to include(title: output_title, units:, labels:, range:)
    end

    it 'sessions are response types generated within given range' do
      expect_in_range
    end
  end

  context 'when events are not responded' do
    before do
      create_list :discovery_service_event,
                  20,
                  initiating_sp: service_provider.entity_id,
                  timestamp: 1.day.ago.beginning_of_day
    end

    let(:value) { 0.00 }
    let(:source) { 'DS' }

    it 'should not count any sessions' do
      expect_in_range
    end
  end

  context 'when IdP events are failed' do
    before do
      create_list :federated_login_event,
                  20,
                  relying_party: service_provider.entity_id,
                  timestamp: 1.day.ago.beginning_of_day
    end

    let(:value) { 0.00 }
    let(:source) { 'IdP' }

    it 'should not count any sessions' do
      expect_in_range
    end
  end

  shared_examples 'when events timestamps are specified manually' do
    before :example do
      [*1..5].each do |n|
        create_event(n.days.ago.beginning_of_day)
        create_event(n.days.ago.beginning_of_day + 10.minutes)
        create_event(n.days.ago.end_of_day)
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

  context 'when events are sessions with response' do
    def create_event(timestamp = nil)
      create :discovery_service_event,
             :response,
             {
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider.entity_id,
               timestamp:
             }.compact
    end

    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

    it_behaves_like 'a report procesing events from the selected source'
    it_behaves_like 'when events timestamps are specified manually'
  end

  context 'when events are IdP sessions' do
    def create_event(timestamp = nil)
      create :federated_login_event,
             :OK,
             {
               asserting_party: identity_provider.entity_id,
               relying_party: service_provider.entity_id,
               timestamp:
             }.compact
    end

    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

    it_behaves_like 'a report procesing events from the selected source'
    it_behaves_like 'when events timestamps are specified manually'
  end
end
