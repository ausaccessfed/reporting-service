require 'rails_helper'

RSpec.describe IdentityProviderSessionsReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'identity-provider-sessions' }
  let(:title) { 'Identity Provider Sessions for' }

  let(:labels) { { y: 'Sessions / hour (average)', sessions: 'Sessions / h' } }
  let(:units) { '' }

  let!(:start) { 10.days.ago.beginning_of_day }
  let!(:finish) { 1.day.ago.end_of_day }

  let!(:range) { { start: start.xmlschema, end: finish.xmlschema } }
  let(:steps) { 5 }

  let(:scope_range) do
    (0..(finish - start).to_i).step(steps.hours.to_i)
  end

  let(:idp) { create :identity_provider }
  let(:idp_2) { create :identity_provider }
  let(:sp) { create :service_provider }

  subject do
    IdentityProviderSessionsReport.new(idp.entity_id, start, finish, steps)
  end

  let(:report) { subject.generate }
  let(:data) { report[:data] }

  def expect_in_range
    [*scope_range].each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, value])
    end
  end

  context 'when events are sessions with response' do
    before do
      create_list :discovery_service_event, 20, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp.entity_id
    end

    let(:value) { anything }

    it 'should include title, units, labels and range' do
      output_title = title + ' ' + idp.name
      expect(report).to include(title: output_title, units: units,
                                labels: labels, range: range)
    end

    it 'sessions should be generated within given range' do
      expect_in_range
    end
  end

  context 'when IdP sessions are not yet completed' do
    before do
      create_list :discovery_service_event, 2,
                  initiating_sp: sp.entity_id
    end

    let(:value) { 0.0 }

    it 'should not count IdP sessions' do
      expect_in_range
    end
  end

  context 'when IdPs have sessions' do
    before :example do
      create_list :discovery_service_event, 5, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp.entity_id,
                  timestamp: start

      create_list :discovery_service_event, 10, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp.entity_id,
                  timestamp: finish - 2.days

      create_list :discovery_service_event, 9, :response,
                  selected_idp: idp.entity_id,
                  initiating_sp: sp.entity_id,
                  timestamp: finish

      create_list :discovery_service_event, 9, :response,
                  selected_idp: idp_2.entity_id,
                  initiating_sp: sp.entity_id,
                  timestamp: finish
    end

    it 'average should be 1.0 for 5 IdP sessions during first 5 hours' do
      time = [*scope_range].first
      expect(data[:sessions]).to include([time, 1.0])
    end

    it 'should contain 2.0 IdP sessions/h during first 5 hours of 2 days ago' do
      expect(data[:sessions]).to include([684_000, 2.0])
    end

    it 'average should be 0.0 for no IdP sessions during 2nd last 5 hours' do
      time = [*scope_range][-2]
      expect(data[:sessions]).to include([time, 0.0])
    end

    it 'average should be 1.8 for 9 IdP sessions during last 5 hours' do
      time = [*scope_range].last
      expect(data[:sessions]).to include([time, 1.8])
    end
  end
end
