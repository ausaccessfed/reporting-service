require 'rails_helper'

RSpec.describe DiscoveryServiceEvent, type: :model do
  around { |spec| Timecop.freeze { spec.run } }

  context 'validations' do
    subject { create :discovery_service_event }

    it { is_expected.to validate_presence_of(:user_agent) }
    it { is_expected.to validate_presence_of(:service_provider) }
    it { is_expected.to validate_presence_of(:ip) }
    it { is_expected.to validate_presence_of(:unique_id) }
    it { is_expected.to validate_presence_of(:phase) }
  end

  context 'sessions' do
    let!(:start) { 10.days.ago.beginning_of_day }
    let!(:finish) { 1.days.ago.beginning_of_day }

    let!(:identity_provider) { create :identity_provider }
    let!(:service_provider) { create :service_provider }

    %w(before_start after_finish).each do |event|
      let("event_#{event}".to_sym) do
        create :discovery_service_event, :response,
               identity_provider: identity_provider,
               service_provider: service_provider,
               timestamp:
               event == :before_start ? start - 1.second : finish + 1.second
      end
    end

    let!(:events_within_range) do
      create_list :discovery_service_event, 20, :response,
                  identity_provider: identity_provider,
                  service_provider: service_provider,
                  timestamp: Faker::Time.between(start, finish)
    end

    let(:none_session_event) do
      create :discovery_service_event,
             timestamp: Faker::Time.between(start, finish)
    end

    let(:sessions) do
      DiscoveryServiceEvent.within_range(start, finish).sessions.sort
    end

    it 'should not select session out of range' do
      expect(sessions).not_to include(event_before_start)
      expect(sessions).not_to include(event_after_finish)
    end

    it 'should select sessions within given range' do
      expect(sessions).to match_array(events_within_range.sort)
    end

    it 'should select not none sessions events' do
      expect(sessions).not_to include(none_session_event)
    end
  end
end
