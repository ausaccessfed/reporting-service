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

  let!(:activation) do
    [organization, identity_provider,
     service_provider, rapid_connect_service]
      .map { |o| create(:activation, federation_object: o) }
  end

  subject { FederationGrowthReport.new(title, start, finish) }

  shared_examples 'a report which generates growth analytics' do
    let(:start) { Time.zone.today - 10.days }
    let(:finish) { Time.zone.today }
    let(:range) { { start: start.xmlschema, end: finish.xmlschema } }

    context 'growth report generate' do
      it 'includes title, units, lables and range' do
        expect(subject.generate).to include(title: title, units: units,
                                            labels: labels, range: range)
      end

      it 'includes unique activations only' do
        expect(subject.generate)
          .to include(data: (include "#{type}": include([0, 1])))
      end

      context 'with deactivated objects' do
        let!(:activation_02) do
          [organization, identity_provider,
           service_provider, rapid_connect_service]
            .map do |o|
              create(:activation, federation_object: o, deactivated_at: start)
            end
        end

        it 'does not include deactivated objects' do
          expect(subject.generate)
            .not_to include(data: (include "#{type}": include([0, 2])))
        end
      end

      context 'with dublicate object ids' do
        let!(:activation_03) do
          [organization, identity_provider,
           service_provider, rapid_connect_service]
            .map { |o| create(:activation, federation_object: o) }
        end

        it 'does not include dublicate activations' do
          expect(subject.generate)
            .not_to include(data: (include "#{type}": include([0, 2])))
        end
      end

      context 'with objects deactivated after current point' do
        let!(:activation_deactivated_latter) do
          [organization_02, identity_provider_02,
           service_provider_02, rapid_connect_service_02]
            .map do |o|
              create(:activation, federation_object: o,
                                  deactivated_at: start + 1.day)
            end
        end

        it 'shoud count objects if deactivated after current point' do
          expect(subject.generate)
            .to include(data: (include "#{type}": include([0, 2])))
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
