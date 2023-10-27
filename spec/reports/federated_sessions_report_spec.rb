# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FederatedSessionsReport do
  subject { described_class.new(start, finish, steps, source) }

  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'federated-sessions' }
  let(:report) { subject.generate }
  let(:data) { report[:data] }
  let(:title) { 'Federated Sessions' }
  let(:units) { '' }
  let(:labels) { { y: 'Sessions / hour (average)', sessions: 'Sessions' } }

  let(:start) { 10.days.ago.beginning_of_day }
  let(:finish) { 1.day.ago.end_of_day }

  let(:steps) { 5 }

  let(:range) { { start: start.strftime('%FT%H:%M:%S%z'), end: finish.strftime('%FT%H:%M:%S%z') } }

  let(:scope_range) { (0..(finish - start).to_i).step(steps.hours.to_i) }

  let(:identity_provider) { create(:identity_provider) }
  let(:service_provider) { create(:service_provider) }



  def expect_in_range
    scope_range.each_with_index { |t, index| expect(data[:sessions][index]).to contain_exactly(t, value) }
  end

  shared_examples 'a report procesing events from the selected source' do
    before { 20.times { create_event } }

    let(:value) { anything }

    it 'includes title, units, labels and range' do
      output_title = "#{title} (#{source_name})"
      expect(report).to include(title: output_title, units:, labels:, range:)
    end

    it 'sessions should be generated within given range' do
      expect_in_range
    end
  end

  context 'when events are not responded' do
    before do
      create_list(:discovery_service_event,
                  20,
                  initiating_sp: service_provider.entity_id,
                  timestamp: 1.day.ago.beginning_of_day)
    end

    let(:value) { 0.0 }
    let(:source) { 'DS' }

    it 'does not count any sessions' do
      expect_in_range
    end
  end

  context 'when IdP events are failed' do
    before do
      create_list(:federated_login_event,
                  20,
                  relying_party: service_provider.entity_id,
                  timestamp: 1.day.ago.beginning_of_day)
    end

    let(:value) { 0.0 }
    let(:source) { 'IdP' }

    it 'does not count any sessions' do
      expect_in_range
    end
  end

  shared_examples 'when events timestamps are specified manually' do
    before do
      5.times { create_event(start) }
      10.times { create_event(2.days.ago.beginning_of_day) }
      9.times { create_event(finish) }
    end

    it 'average should be 1.0 for 5 sessions during first 5 hours' do
      time = [*scope_range].first
      expect(data[:sessions]).to include([time, 1.0])
    end

    it 'contains 2.0 sessions/h during first 5 hours of 2 days ago' do
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

  context 'when events are sessions with response' do
    def create_event(timestamp = nil)
      create(:discovery_service_event,
             :response,
             {
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider.entity_id,
               timestamp:
             }.compact)
    end

    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

    it_behaves_like 'a report procesing events from the selected source'
    it_behaves_like 'when events timestamps are specified manually'
  end

  context 'when events are IdP sessions' do
    def create_event(timestamp = nil)
      create(:federated_login_event,
             :OK,
             {
               asserting_party: identity_provider.entity_id,
               relying_party: service_provider.entity_id,
               timestamp:
             }.compact)
    end

    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

    it_behaves_like 'a report procesing events from the selected source'
    it_behaves_like 'when events timestamps are specified manually'
  end
end
