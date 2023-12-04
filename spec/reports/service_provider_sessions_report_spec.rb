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

  let(:range) { { start: start.strftime('%FT%H:%M:%S%z'), end: finish.strftime('%FT%H:%M:%S%z') } }

  let(:steps) { 5 }

  let(:scope_range) { (0..(finish - start).to_i).step(steps.hours.to_i) }

  let(:idp) { create(:identity_provider) }
  let(:sp_01) { create(:service_provider) }
  let(:sp_02) { create(:service_provider) }

  subject { ServiceProviderSessionsReport.new(sp_01.entity_id, start, finish, steps, source) }

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    [*scope_range].each_with_index { |t, index| expect(data[:sessions][index]).to match_array([t, value]) }
  end

  shared_examples 'sessions' do
    before { 20.times { create_event(idp.entity_id, sp_01.entity_id) } }

    let(:value) { anything }

    it 'should include title, units, labels and range' do
      output_title = "#{title} #{sp_01.name} (#{source_name})"
      expect(report).to include(title: output_title, units:, labels:, range:)
    end

    it 'sessions should be generated within given range' do
      expect_in_range
    end
  end

  context 'when SP sessions are not yet responded' do
    before { create_list(:discovery_service_event, 2, initiating_sp: sp_01.entity_id) }

    let(:value) { 0.0 }
    let(:source) { 'DS' }

    it 'should not count SP sessions' do
      expect_in_range
    end
  end

  context 'when SP sessions are failed at IdP' do
    before { create_list(:federated_login_event, 2, relying_party: sp_01.entity_id) }

    let(:value) { 0.0 }
    let(:source) { 'IdP' }

    it 'should not count SP sessions' do
      expect_in_range
    end
  end

  shared_examples 'SPs with sessions' do
    before :example do
      5.times { create_event(idp.entity_id, sp_01.entity_id, start) }
      10.times { create_event(idp.entity_id, sp_01.entity_id, finish - 2.days) }
      9.times { create_event(idp.entity_id, sp_01.entity_id, finish) }
      9.times { create_event(idp.entity_id, sp_02.entity_id, finish) }
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

  context 'when events are sessions with response' do
    def create_event(idp, sp, timestamp = nil)
      create(:discovery_service_event, :response, { selected_idp: idp, initiating_sp: sp, timestamp: }.compact)
    end

    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

    it_behaves_like 'sessions'
    it_behaves_like 'SPs with sessions'
  end

  context 'when events are IdP sessions' do
    def create_event(idp, sp, timestamp = nil)
      create(:federated_login_event, :OK, { asserting_party: idp, relying_party: sp, timestamp: }.compact)
    end

    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

    it_behaves_like 'sessions'
    it_behaves_like 'SPs with sessions'
  end
end
