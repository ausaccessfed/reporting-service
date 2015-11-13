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
  let(:int_range) { (0..(finish.to_i - start.to_i)).step(1.day) }

  let(:count_in_range) do
    type_count = { organizations: 1, identity_providers: 1, services: 2 }
    total_array = [1, 2, 4]
    counter = 0

    int_range.each do |time|
      stamp = 0
      type_count.map do |k, val|
        total = total_array[stamp]
        expect(report[:data][k][counter]).to match_array([time, total, val])
        stamp += 1
      end
      counter += 1
    end
  end

  [:organization, :identity_provider,
   :rapid_connect_service, :service_provider].each do |type|
    let(type) { create type }
    let("#{type}_02") { create type }
  end

  before :example do
    [organization, identity_provider,
     rapid_connect_service, service_provider]
      .each { |o| create(:activation, federation_object: o) }
  end

  subject { FederationGrowthReport.new(title, start, finish) }
  let(:report) { subject.generate }

  shared_examples 'a report which generates growth analytics' do
    context 'growth report when some objects are not included' do
      before :example do
        included_objects
          .each { |o| create(:activation, federation_object: o) }
      end

      it 'will not fail if some object types are not existing' do
        count_in_range
      end
    end
  end

  context 'report generation' do
    context 'for Organizations' do
      let(:type) { :organizations }
      let(:included_objects) { [organization] }
      let(:excluded_objects) do
        [identity_provider, service_provider, rapid_connect_service]
      end

      it_behaves_like 'a report which generates growth analytics'
    end

    context 'for Identity Providers' do
      let(:type) { :identity_providers }
      let(:included_objects) { [identity_provider] }
      let(:excluded_objects) do
        [organization, service_provider, rapid_connect_service]
      end

      it_behaves_like 'a report which generates growth analytics'
    end

    context 'for Services' do
      let(:type) { :services }
      let(:included_objects) { [service_provider, rapid_connect_service] }
      let(:excluded_objects) { [organization, identity_provider] }

      it_behaves_like 'a report which generates growth analytics'
    end
  end

  context '#generate report' do
    let(:report) { subject.generate }

    it 'output structure should match stacked_report' do
      [:organizations,
       :identity_providers, :services].each do |type|
        report[:data][type].each { |i| expect(i.count).to eq(3) }
      end
    end

    it 'includes title, units, lables and range' do
      expect(report).to include(title: title, units: units,
                                labels: labels, range: range)
    end

    context 'with objects deactivated before start' do
      before :example do
        [organization_02, identity_provider_02,
         service_provider_02, rapid_connect_service_02]
          .each do |o|
            create(:activation, federation_object: o,
                                deactivated_at: (start - 1.day))
          end
      end

      it 'shoud not count objects if deactivated before starting point' do
        count_in_range
      end
    end

    context 'with dublicate dublicate' do
      before :example do
        [organization, identity_provider,
         rapid_connect_service, service_provider]
          .each { |o| create(:activation, federation_object: o) }
      end

      it 'data sholud hold number of unique types on each point' do
        count_in_range
      end
    end

    context 'with objects deactivated within the range' do
      let(:midtime) { start + ((finish - start) / 2) }
      let(:midtime_point) { (finish - midtime).to_i }
      let(:before_midtime) { (0...(midtime.to_i - start.to_i)).step(1.day) }
      let(:after_midtime) do
        ((midtime.to_i - start.to_i)..(finish.to_i - start.to_i)).step(1.day)
      end

      before :example do
        [organization_02, identity_provider_02,
         service_provider_02, rapid_connect_service_02]
          .each do |o|
            create(:activation, federation_object: o,
                                deactivated_at: midtime)
          end
      end

      xit 'shoud count objects before deactivation'
      xit 'shoud not count objects after deactivation'
    end
  end
end
