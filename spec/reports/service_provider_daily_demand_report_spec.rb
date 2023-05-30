# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceProviderDailyDemandReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'service-provider-daily-demand' }
  let(:title) { 'SP Daily Demand Report for' }
  let(:units) { '' }
  let(:labels) { { y: 'Sessions / hour (average)', sessions: 'Sessions' } }

  let(:start) { 10.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:range) do
    { start: start.strftime('%FT%H:%M:%S%z'),
      end: finish.strftime('%FT%H:%M:%S%z') }
  end

  let(:identity_provider) { create :identity_provider }
  let(:service_provider_01) { create :service_provider }
  let(:service_provider_02) { create :service_provider }

  subject do
    ServiceProviderDailyDemandReport
      .new(service_provider_01.entity_id, start, finish, source)
  end

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    (0..86_340).step(300).each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, value])
    end
  end

  shared_examples 'a report procesing events from the selected source' do
    before do
      5.times do
        create_event(identity_provider.entity_id, service_provider_01.entity_id)
      end
    end

    let(:value) { anything }

    it 'should include title, units and labels' do
      output_title = "#{title} #{service_provider_01.name} (#{source_name})"
      expect(report).to include(title: output_title,
                                units:, labels:, range:)
    end

    it 'sessions generated within given range' do
      expect_in_range
    end
  end

  context 'sessions without response' do
    before do
      create_list :discovery_service_event, 10,
                  initiating_sp: service_provider_01.entity_id,
                  timestamp: 1.day.ago.beginning_of_day
    end

    let(:value) { 0.00 }
    let(:source) { 'DS' }

    it 'should not count any sessions' do
      expect_in_range
    end
  end

  context 'when failed event' do
    before do
      create_list :federated_login_event, 10,
                  relying_party: service_provider_01.entity_id,
                  timestamp: 1.day.ago.beginning_of_day
    end

    let(:value) { 0.00 }
    let(:source) { 'IdP' }

    it 'should not count any sessions' do
      expect_in_range
    end
  end

  shared_examples 'events at different times' do
    before :example do
      [*1..5].each do |n|
        create_event(identity_provider.entity_id,
                     service_provider_01.entity_id,
                     n.days.ago.beginning_of_day)

        create_event(identity_provider.entity_id,
                     service_provider_01.entity_id,
                     n.days.ago.beginning_of_day + 15.minutes)

        create_event(identity_provider.entity_id,
                     service_provider_01.entity_id,
                     n.days.ago.end_of_day)

        create_event(identity_provider.entity_id,
                     service_provider_02.entity_id,
                     n.days.ago.end_of_day)
      end
    end

    it 'average at point 0 should be 0.5 for 5 sessions in 10 days' do
      expect(data[:sessions]).to include([0, 0.45])
    end

    it 'average should be 0.0 when no sessions available at point 300' do
      expect(data[:sessions]).to include([300, 0.0])
    end

    it 'average at point 900 should be 0.5 for 5 sessions in 10 days' do
      expect(data[:sessions]).to include([900, 0.45])
    end

    it 'should not include sessions for irrelevant SP (average must be 0.5)' do
      expect(data[:sessions]).to include([86_100, 0.45])
    end
  end

  context 'sessions with response' do
    def create_event(idp, sp, timestamp = nil)
      create :discovery_service_event, :response,
             { selected_idp: idp,
               initiating_sp: sp,
               timestamp: }.compact
    end

    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

    it_behaves_like 'a report procesing events from the selected source'
    it_behaves_like 'events at different times'
  end

  context 'IdP sessions' do
    def create_event(idp, sp, timestamp = nil)
      create :federated_login_event, :OK,
             { asserting_party: idp,
               relying_party: sp,
               timestamp: }.compact
    end

    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

    it_behaves_like 'a report procesing events from the selected source'
    it_behaves_like 'events at different times'
  end
end
