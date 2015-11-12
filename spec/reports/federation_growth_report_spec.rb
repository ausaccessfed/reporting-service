require 'rails_helper'

RSpec.describe FederationGrowthReport do
  let(:title) { 'title' }
  let(:units) { '' }
  let(:labels) do
    { y: '', organizations: 'Organizations',
      identity_providers: 'Identity Providers',
      services: 'Services' }
  end

  let(:start) { Time.zone.now - 1.week }
  let(:finish) { Time.zone.now }
  let!(:range) { { start: start.xmlschema, end: finish.xmlschema } }

  [:organization, :identity_provider,
   :rapid_connect_service, :service_provider].each do |type|
    let(type) { create type }
  end

  subject { FederationGrowthReport.new(title, start, finish) }

  context '#generate report' do
    let(:report) { subject.generate }

    before :example do
      [organization, identity_provider,
       rapid_connect_service, service_provider]
        .each { |o| create(:activation, federation_object: o) }
    end

    it 'must include series ' do
      expect(report).to include(title: title, units: units,
                                labels: labels, range: range)
    end

    it 'output structure should match stacked_report' do
      [:organizations,
       :identity_providers, :services].each do |type|
        report[:data][type].each { |i| expect(i.count).to eq(3) }
      end
    end

    context 'within some range' do
      let(:start) { Time.zone.now }
      let(:finish) { Time.zone.now }
      let(:range) { (0..(finish.to_i - start.to_i)).step(1.day) }
      let(:total_array) { [1, 2, 4, 1, 2, 4, 1, 2, 4] }
      let(:type_count) do
        { organizations: 1, identity_providers: 1, services: 2 }
      end

      it 'data sholud hold number of each type and seconds on each point' do
        counter = 0

        range.each do |time|
          stamp = 0

          type_count.map do |k, val|
            total = total_array[stamp]
            expect(report[:data][k][counter]).to match_array([time, total, val])
            stamp += 1
          end
          counter += 1
        end
      end
    end
  end
end
