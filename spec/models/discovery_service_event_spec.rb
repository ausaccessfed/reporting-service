# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscoveryServiceEvent do
  around { |spec| Timecop.freeze { spec.run } }

  context 'validations' do
    subject { create(:discovery_service_event) }

    it { is_expected.not_to validate_presence_of(:user_agent) }
    it { is_expected.to validate_presence_of(:initiating_sp) }
    it { is_expected.to validate_presence_of(:ip) }
    it { is_expected.to validate_presence_of(:unique_id) }
    it { is_expected.to validate_presence_of(:phase) }

    it 'allows long user_agent values' do
      expect(subject).to allow_value('.' * 4000).for(:user_agent)
    end
  end

  context 'sessions' do
    let(:start) { 10.days.ago.beginning_of_day }
    let(:finish) { 1.day.ago.end_of_day }

    let(:identity_provider) { create(:identity_provider) }
    let(:service_provider) { create(:service_provider) }

    let(:event_before_start) do
      create(:discovery_service_event,
             :response,
             selected_idp: identity_provider.entity_id,
             initiating_sp: service_provider.entity_id,
             timestamp: start - 1.second)
    end

    let(:event_after_finish) do
      create(:discovery_service_event,
             :response,
             selected_idp: identity_provider.entity_id,
             initiating_sp: service_provider.entity_id,
             timestamp: finish + 1.second)
    end

    let(:events_within_range) do
      [*1..10].map do |t|
        create(:discovery_service_event,
               :response,
               selected_idp: identity_provider.entity_id,
               initiating_sp: service_provider.entity_id,
               timestamp: [t.days.ago.end_of_day, t.days.ago.beginning_of_day].sample)
      end
    end

    let(:none_session_event) { create(:discovery_service_event, timestamp: 4.days.ago) }

    let(:sessions) { described_class.within_range(start, finish).sessions }

    it 'does not select session out of range' do
      expect(sessions).not_to include(event_before_start)
      expect(sessions).not_to include(event_after_finish)
    end

    it 'selects sessions within given range' do
      expect(sessions).to match_array(events_within_range)
    end

    it 'selects not none sessions events' do
      expect(sessions).not_to include(none_session_event)
    end
  end
end
