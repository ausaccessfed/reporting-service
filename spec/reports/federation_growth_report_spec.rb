require 'rails_helper'

RSpec.describe FederationGrowthReport do
  let(:title) { 'title' }
  let(:units) { '' }
  let(:labels) do
    { y: '', organizations: 'Organizations',
      identity_providers: 'Identity Providers',
      service_providers: 'Service Providers',
      rapid_connect_services: 'Rapid Connect Services' }
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
    before :example do
      [organization, identity_provider,
       service_provider, rapid_connect_service]
        .map { |o| create(:activation, federation_object: o) }
    end

    context 'growth report generate' do
      it 'includes title, units, lables and range' do
        expect(subject.generate).to include(title: title, units: units,
                                            labels: labels, range: range)
      end

      it 'includes unique activations only' do
        expect(subject.generate)
          .to include(data: (include "#{type}": include([anything, 1])))
      end

      context 'with dublicate object ids' do
        before :example do
          [organization, identity_provider,
           service_provider, rapid_connect_service]
            .map { |o| create(:activation, federation_object: o) }
        end

        it 'should not include dublicate activations' do
          expect(subject.generate)
            .not_to include(data: (include "#{type}": include([anything, 2])))
        end
      end

      context 'with deactivated objects' do
        before :example do
          [organization, identity_provider,
           service_provider, rapid_connect_service]
            .map do |o|
              create(:activation, federation_object: o, deactivated_at: start)
            end
        end

        it 'should not include deactivated objects' do
          expect(subject.generate)
            .not_to include(data: (include "#{type}": include([anything, 2])))
        end
      end

      context 'with objects deactivated before start' do
        before :example do
          [organization_02, identity_provider_02,
           service_provider_02, rapid_connect_service_02]
            .map do |o|
              create(:activation, federation_object: o,
                                  deactivated_at: (start - 1.day))
            end
        end

        it 'shoud not count objects if deactivated before starting point' do
          expect(subject.generate)
            .not_to include(data: (include "#{type}": include([anything, 2])))
        end
      end

      context 'with objects deactivated within the range' do
        let(:midtime) { start + ((finish - start) / 2) }

        before :example do
          [organization_02, identity_provider_02,
           service_provider_02, rapid_connect_service_02]
            .map do |o|
              create(:activation, federation_object: o,
                                  deactivated_at: midtime)
            end
        end

        it 'shoud count objects before deactivated_at' do
          expect(subject.generate)
            .not_to include(data: (include "#{type}": include([midtime, 2])))
        end
      end
    end
  end

  context 'report generation' do
    context 'for Organizations' do
      let(:type) { :organizations }

      it_behaves_like 'a report which generates growth analytics'
    end

    context 'for Identity Providers' do
      let(:type) { :identity_providers }

      it_behaves_like 'a report which generates growth analytics'
    end

    context 'for Service Providers' do
      let(:type) { :service_providers }

      it_behaves_like 'a report which generates growth analytics'
    end

    context 'for Rapid Connect Services' do
      let(:type) { :rapid_connect_services }

      it_behaves_like 'a report which generates growth analytics'
    end
  end
end
