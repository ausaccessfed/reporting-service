# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServiceProviderDailyDemandReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'service-provider-daily-demand' }
  let(:title) { 'SP Daily Demand Report for' }
  let(:units) { '' }
  let(:labels) { { y: 'Sessions / hour (average)', sessions: 'Sessions' } }

  let!(:zone) { Faker::Address.time_zone }
  let(:start) { 10.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:range) do
    { start: start.in_time_zone(zone).xmlschema,
      end: finish.in_time_zone(zone).xmlschema }
  end

  let(:identity_provider) { create :identity_provider }
  let(:service_provider_01) { create :service_provider }
  let(:service_provider_02) { create :service_provider }

  subject do
    ServiceProviderDailyDemandReport
      .new(service_provider_01.entity_id, start, finish)
  end

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    (0..86_340).step(300).each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, value])
    end
  end

  before do
    allow(Rails.application)
      .to receive_message_chain(:config, :reporting_service, :time_zone)
      .and_return(zone)
  end

  context 'sessions with response' do
    before do
      create_list :discovery_service_event, 5, :response,
                  selected_idp: identity_provider.entity_id,
                  initiating_sp: service_provider_01.entity_id
    end

    let(:value) { anything }

    it 'should include title, units and labels' do
      output_title = title + ' ' + service_provider_01.name
      expect(report).to include(title: output_title,
                                units: units, labels: labels, range: range)
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

    it 'should not count any sessions' do
      expect_in_range
    end
  end

  context 'events at different times' do
    before :example do
      [*1..5].each do |n|
        create :discovery_service_event, :response,
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider_01.entity_id,
               timestamp: n.days.ago.beginning_of_day

        create :discovery_service_event, :response,
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider_01.entity_id,
               timestamp: n.days.ago.beginning_of_day + 15.minutes

        create :discovery_service_event, :response,
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider_01.entity_id,
               timestamp: n.days.ago.end_of_day

        create :discovery_service_event, :response,
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider_02.entity_id,
               timestamp: n.days.ago.end_of_day
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
end
