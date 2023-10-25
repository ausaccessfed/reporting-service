# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriberRegistrationsReport do
  subject { described_class.new(report_type) }

  let(:header) { [['Name', 'Registration Date']] }
  let(:report) { subject.generate }
  let(:type) { 'subscriber-registrations' }

  let(:organization) { create(:organization) }
  let(:identity_provider) { create(:identity_provider) }
  let(:service_provider) { create(:service_provider) }
  let(:rapid_connect_service) { create(:rapid_connect_service) }

  shared_examples 'a report which lists federation objects' do
    it 'returns an array' do
      expect(report[:rows]).to be_an(Array)
    end

    it 'produces title, header and type' do
      expect(report).to include(title:, header:, type:)
    end

    context 'when all objects are activated' do
      let!(:activations) do
        [*reported_objects, *excluded_objects].each { |o| create(:activation, federation_object: o) }
      end

      it 'includes reported objects' do
        reported_objects.each do |o|
          activated_date = o.activations.reload.flat_map(&:activated_at).min

          expect(report[:rows]).to include([o.name, activated_date])
        end
      end
    end

    context 'when all objects are deactivated' do
      let!(:activations) do
        [*reported_objects, *excluded_objects].each { |o| create(:activation, :deactivated, federation_object: o) }
      end

      it 'excludes all objects' do
        [*reported_objects, *excluded_objects].each { |o| expect(report[:rows]).not_to include([o.name, anything]) }
      end
    end

    context 'when objects have no activations' do
      it 'excludes object without activations' do
        [*reported_objects, *excluded_objects].each { |o| expect(report[:rows]).not_to include([o.name, anything]) }
      end
    end
  end

  context 'report generation' do
    context 'invalid indetifier' do
      let(:report_type) { 'asdsad' }

      it 'thows an error' do
        expect { report }.to raise_error('Identifier is not valid!')
      end
    end

    context 'for an Organization' do
      let(:report_type) { 'organizations' }
      let(:title) { 'Registered Organizations' }
      let(:reported_objects) { [organization] }
      let(:excluded_objects) { [identity_provider, service_provider, rapid_connect_service] }

      it_behaves_like 'a report which lists federation objects'
    end

    context 'for an Identity Provider' do
      let(:report_type) { 'identity_providers' }
      let(:title) { 'Registered Identity Providers' }
      let(:reported_objects) { [identity_provider] }
      let(:excluded_objects) { [organization, service_provider, rapid_connect_service] }

      it_behaves_like 'a report which lists federation objects'
    end

    context 'for a Service Provider' do
      let(:report_type) { 'service_providers' }
      let(:title) { 'Registered Service Providers' }
      let(:reported_objects) { [service_provider] }
      let(:excluded_objects) { [organization, identity_provider, rapid_connect_service] }

      it_behaves_like 'a report which lists federation objects'
    end

    context 'for a Rapid Connect Service' do
      let(:report_type) { 'rapid_connect_services' }
      let(:title) { 'Registered Rapid Connect Services' }
      let(:reported_objects) { [rapid_connect_service] }
      let(:excluded_objects) { [organization, identity_provider, service_provider] }

      it_behaves_like 'a report which lists federation objects'
    end

    context 'for a Service' do
      let(:report_type) { 'services' }
      let(:title) { 'Registered Services' }
      let(:reported_objects) { [service_provider, rapid_connect_service] }
      let(:excluded_objects) { [organization, identity_provider] }

      it_behaves_like 'a report which lists federation objects'
    end
  end
end
