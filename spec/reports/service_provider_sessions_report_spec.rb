# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceProviderSessionsReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'service-provider-sessions' }
  let(:title) { 'Service Provider Sessions for' }

  let(:labels) { { y: 'Sessions / hour (average)', sessions: 'Sessions' } }
  let(:units) { '' }

  let(:start) { 10.days.ago.beginning_of_day }
  let(:finish) { 1.day.ago.end_of_day }

  let(:range) do
    { start: start.strftime('%FT%H:%M:%S%z'),
      end: finish.strftime('%FT%H:%M:%S%z') }
  end

  let(:steps) { 5 }

  let(:scope_range) do
    (0..(finish - start).to_i).step(steps.hours.to_i)
  end

  let(:idp) { create :identity_provider }
  let(:sp_01) { create :service_provider }
  let(:sp_02) { create :service_provider }

  subject do
    ServiceProviderSessionsReport.new(sp_01.entity_id, start, finish, steps)
  end

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    [*scope_range].each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, value])
    end
  end

  context 'sessions' do
    before do
      create_list :discovery_service_event, 20, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp_01.entity_id
    end

    let(:value) { anything }

    it 'should include title, units, labels and range' do
      output_title = title + ' ' + sp_01.name
      expect(report).to include(title: output_title, units: units,
                                labels: labels, range: range)
    end

    it 'sessions should be generated within given range' do
      expect_in_range
    end
  end

  context 'when SP sessions are not yet responded' do
    before do
      create_list :discovery_service_event, 2,
                  initiating_sp: sp_01.entity_id
    end

    let(:value) { 0.0 }

    it 'should not count SP sessions' do
      expect_in_range
    end
  end

  context 'SPs with sessions' do
    before :example do
      create_list :discovery_service_event, 5, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp_01.entity_id,
                  timestamp: start

      create_list :discovery_service_event, 10, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp_01.entity_id,
                  timestamp: finish - 2.days

      create_list :discovery_service_event, 9, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp_01.entity_id,
                  timestamp: finish

      create_list :discovery_service_event, 9, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp_02.entity_id,
                  timestamp: finish
    end

    it 'average should be 1.0 for 5 SP sessions during first 5 hours' do
      time = [*scope_range].first
      expect(data[:sessions]).to include([time, 1.0])
    end

    it 'should contain 2.0 SP sessions/h during first 5 hours of 2 days ago' do
      expect(data[:sessions]).to include([684_000, 2.0])
    end

    it 'average should be 0.0 for no SP sessions during 2nd last 5 hours' do
      time = [*scope_range][-2]
      expect(data[:sessions]).to include([time, 0.0])
    end

    it 'average should be 1.8 for 9 SP sessions during last 5 hours' do
      time = [*scope_range].last
      expect(data[:sessions]).to include([time, 1.8])
    end
  end
end
