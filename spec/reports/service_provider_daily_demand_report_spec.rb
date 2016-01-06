require 'rails_helper'

RSpec.describe ServiceProviderDailyDemandReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'service-provider-daily-demand' }
  let(:title) { 'SP Daily Demand Report for' }
  let(:units) { '' }
  let(:labels) { { y: '', sessions: 'demand' } }

  let(:start) { 10.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

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
    (0..(86_340)).step(60).each_with_index do |t, index|
      expect(data[:sessions][index]).to match_array([t, value])
    end
  end

  context 'sessions with response' do
    before do
      create_list :discovery_service_event, 5, :response,
                  identity_provider: identity_provider,
                  service_provider: service_provider_01
    end

    let(:value) { anything }

    it 'should include title, units and labels' do
      output_title = title + ' ' + service_provider_01.name
      expect(report).to include(title: output_title,
                                units: units, labels: labels)
    end

    it 'should not include range' do
      expect(report).not_to include(:range)
    end

    it 'sessions generated within given range' do
      expect_in_range
    end
  end
end
