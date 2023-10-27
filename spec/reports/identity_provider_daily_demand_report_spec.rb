# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentityProviderDailyDemandReport do
  subject { described_class.new(identity_provider_01.entity_id, start, finish, source) }

  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'identity-provider-daily-demand' }
  let(:report) { subject.generate }
  let(:data) { report[:data] }
  let(:title) { 'IdP Daily Demand Report for' }
  let(:units) { '' }
  let(:labels) { { y: 'Sessions / hour (average)', sessions: 'Sessions' } }

  let(:start) { 10.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:range) { { start: start.strftime('%FT%H:%M:%S%z'), end: finish.strftime('%FT%H:%M:%S%z') } }

  let(:identity_provider_01) { create(:identity_provider) }
  let(:identity_provider_02) { create(:identity_provider) }
  let(:service_provider) { create(:service_provider) }

  def expect_in_range
    (0..86_340).step(300).each_with_index { |t, index| expect(data[:sessions][index]).to contain_exactly(t, value) }
  end

  shared_examples 'a report procesing events from the selected source' do
    before { 5.times { create_event(identity_provider_01.entity_id, service_provider.entity_id) } }

    let(:value) { anything }

    it 'includes title, units and labels' do
      output_title = "#{title} #{identity_provider_01.name} (#{source_name})"
      expect(report).to include(title: output_title, units:, labels:, range:)
    end

    it 'sessions generated within given range' do
      expect_in_range
    end
  end

  context 'when without response' do
    before do
      create_list(
        :discovery_service_event,
        10,
        initiating_sp: service_provider.entity_id,
        timestamp: 1.day.ago.beginning_of_day
      )
    end

    let(:value) { 0.00 }
    let(:source) { 'DS' }

    it 'does not count any sessions' do
      expect_in_range
    end
  end

  context 'when failed event' do
    before do
      create_list(
        :federated_login_event,
        10,
        relying_party: service_provider.entity_id,
        timestamp: 1.day.ago.beginning_of_day
      )
    end

    let(:value) { 0.00 }
    let(:source) { 'IdP' }

    it 'does not count any sessions' do
      expect_in_range
    end
  end

  shared_examples 'events at different times manually' do
    before do
      [*1..5].each do |n|
        create_event(identity_provider_01.entity_id, service_provider.entity_id, n.days.ago.beginning_of_day)

        create_event(
          identity_provider_01.entity_id,
          service_provider.entity_id,
          n.days.ago.beginning_of_day + 10.minutes
        )

        create_event(identity_provider_01.entity_id, service_provider.entity_id, n.days.ago.end_of_day)

        create_event(identity_provider_02.entity_id, service_provider.entity_id, n.days.ago.end_of_day)
      end
    end

    it 'average at point 0 should be 0.5 for 5 sessions in 10 days' do
      expect(data[:sessions]).to include([0, 0.45])
    end

    it 'average should be 0.0 when no sessions available at point 300' do
      expect(data[:sessions]).to include([300, 0.0])
    end

    it 'average at point 600 should be 0.5 for 5 sessions in 10 days' do
      expect(data[:sessions]).to include([600, 0.45])
    end

    it 'does not include sessions for irrelevant IdP (average must be 0.5)' do
      expect(data[:sessions]).to include([86_100, 0.45])
    end
  end

  context 'sessions with response' do
    def create_event(idp, sp, timestamp = nil)
      create(:discovery_service_event, :response, { selected_idp: idp, initiating_sp: sp, timestamp: }.compact)
    end

    let(:source) { 'DS' }
    let(:source_name) { 'Discovery Service' }

    it_behaves_like 'a report procesing events from the selected source'
    it_behaves_like 'events at different times manually'
  end

  context 'IdP sessions' do
    def create_event(idp, sp, timestamp = nil)
      create(:federated_login_event, :OK, { asserting_party: idp, relying_party: sp, timestamp: }.compact)
    end

    let(:source) { 'IdP' }
    let(:source_name) { 'IdP Event Log' }

    it_behaves_like 'a report procesing events from the selected source'
    it_behaves_like 'events at different times manually'
  end
end
