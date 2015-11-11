require 'rails_helper'

RSpec.describe FederationGrowthReport do
  let(:title) { 'title' }
  let(:units) { '' }
  let(:labels) do
    { y: '', organizations: 'Organizations',
      identity_providers: 'Identity Providers',
      services: 'Services' }
  end

  [:organization, :identity_provider,
   :service_provider, :rapid_connect_service].each do |o|
    let(o) { create(o) }
    let("#{o}_02".to_sym) { create(o) }
  end

  let(:start) { Time.zone.now - 10.days }
  let(:finish) { Time.zone.now }
  let(:range) { { start: start.xmlschema, end: finish.xmlschema } }

  subject { FederationGrowthReport.new(title, start, finish) }

  shared_examples 'a report which generates growth analytics' do
    let(:report) { subject.generate }

    context 'growth report generate when all objects are included' do
      before do
        [*included_objects, *excluded_objects]
          .each { |o| create(:activation, federation_object: o) }
      end

      it 'includes title, units, lables and range' do
        expect(report).to include(title: title, units: units,
                                  labels: labels, range: range)
      end

      it 'includes unique activations only' do
        expect(report[:data][type]).to include([anything, total, value])
      end

      context 'with dublicate object ids' do
        before do
          [*included_objects, *excluded_objects]
            .each { |o| create(:activation, federation_object: o) }
        end

        let(:bad_value) { value * 2 }

        it 'should not include dublicate activations' do
          expect(report[:data][type]).not_to include([anything,
                                                      total, bad_value])
        end
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

        let(:bad_value) { value * 2 }
        let(:bad_total) { total + bad_value }

        it 'shoud not count objects if deactivated before starting point' do
          expect(report[:data][type]).not_to include([anything,
                                                      bad_total, bad_value])
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
      end
    end

    context 'growth report when some objects are not included' do
      let!(:activations) do
        included_objects
          .each { |o| create(:activation, federation_object: o) }
      end

      it 'will not fail if some object types are not existing' do
        expect(report[:data][type]).to include([anything, total, value])
      end
    end
  end

  context 'report generation' do
    context 'for Organizations' do
      let(:type) { :organizations }
      let(:value) { 1 }
      let(:total) { 1 }
      let(:included_objects) { [organization] }
      let(:excluded_objects) do
        [identity_provider, service_provider, rapid_connect_service]
      end

      it_behaves_like 'a report which generates growth analytics'
    end

    context 'for Identity Providers' do
      let(:type) { :identity_providers }
      let(:value) { 1 }
      let(:total) { 2 }
      let(:included_objects) { [identity_provider] }
      let(:excluded_objects) do
        [organization, service_provider, rapid_connect_service]
      end

      it_behaves_like 'a report which generates growth analytics'
    end

    context 'for Services' do
      let(:type) { :services }
      let(:value) { 2 }
      let(:total) { 4 }
      let(:included_objects) { [service_provider, rapid_connect_service] }
      let(:excluded_objects) { [organization, identity_provider] }

      it_behaves_like 'a report which generates growth analytics'
    end
  end
end
