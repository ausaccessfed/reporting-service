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
      let!(:activations) do
        [*included_objects, *excluded_objects]
          .each { |o| create(:activation, federation_object: o) }
      end

      it 'includes title, units, lables and range' do
        expect(report).to include(title: title, units: units,
                                  labels: labels, range: range)
      end

      it 'includes unique activations only' do
        expect(report[:data][type]).to include([anything, total, value])
        puts report[:data]
      end

      context 'with dublicate object ids' do
      end

      context 'with deactivated objects' do
      end

      context 'with objects deactivated before start' do
      end

      context 'with objects deactivated within the range' do
      end
    end

    context 'growth report when some objects are not included' do
      let!(:activations) do
        included_objects
          .each { |o| create(:activation, federation_object: o) }
      end

      it 'will not fail if objects are nil' do
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
      let(:total) { 1 }
      let(:included_objects) { [identity_provider] }
      let(:excluded_objects) do
        [organization, service_provider, rapid_connect_service]
      end

      it_behaves_like 'a report which generates growth analytics'
    end

    context 'for Services' do
      let(:type) { :services }
      let(:value) { 2 }
      let(:total) { 2 }
      let(:included_objects) { [service_provider, rapid_connect_service] }
      let(:excluded_objects) { [organization, identity_provider] }

      it_behaves_like 'a report which generates growth analytics'
    end
  end
end
