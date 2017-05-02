# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateFromRapidConnect do
  before(:all) { DatabaseCleaner.clean_with(:truncation) }

  around { |spec| Timecop.freeze { spec.run } }

  let!(:organization) { create(:organization) }
  let(:created_at) { Faker::Time.between(10.days.ago, Time.zone.today, :day) }
  let(:enabled) { true }
  let(:service) do
    {
      id: SecureRandom.urlsafe_base64,
      name: Faker::Company.name,
      created_at: created_at.xmlschema,
      rapidconnect: {
        type: Faker::Lorem.word
      },
      organization: organization.name,
      enabled: enabled
    }
  end

  let(:service_list) { [service] }
  let(:response) { JSON.generate(services: service_list) }

  before do
    stub_request(:get, 'https://rapid.example.edu/export/basic')
      .with(headers: { 'Authorization' => /AAF-RAPID-EXPORT .+/ })
      .to_return(status: 200, body: response)
  end

  def run
    subject.perform
  end

  it 'creates the service' do
    expect { run }.to change(RapidConnectService, :count).by(1)
    expect(RapidConnectService.last)
      .to have_attributes(identifier: service[:id],
                          name: service[:name],
                          service_type: service[:rapidconnect][:type])
  end

  it 'creates an activation' do
    expect { run }.to change(Activation, :count).by(1)
    expect(RapidConnectService.last.activations.first)
      .to have_attributes(activated_at: created_at)
  end

  context 'when the type is missing' do
    let(:service_list) { [service.merge(rapidconnect: {})] }

    it 'uses the default service type' do
      expect { run }.to change(RapidConnectService, :count).by(1)
      expect(RapidConnectService.last)
        .to have_attributes(identifier: service[:id],
                            name: service[:name],
                            service_type: 'research')
    end
  end

  context 'when the service is disabled' do
    let(:enabled) { false }

    it 'does not create the service' do
      expect { run }.not_to change(RapidConnectService, :count)
    end
  end

  context 'with an existing record' do
    let!(:rapid_connect_service) do
      create(:rapid_connect_service, identifier: service[:id])
    end

    let!(:activation) do
      create(:activation, federation_object: rapid_connect_service)
    end

    it 'updates the service' do
      expect { run }.not_to change(RapidConnectService, :count)
      expect(rapid_connect_service.reload)
        .to have_attributes(identifier: service[:id],
                            name: service[:name],
                            service_type: service[:rapidconnect][:type])
    end

    it 'updates the activation' do
      expect { run }.not_to change(Activation, :count)
      expect(activation.reload).to have_attributes(activated_at: created_at)
    end

    context 'when the service is disabled' do
      let(:enabled) { false }

      it 'deletes the service' do
        expect { run }.to change(RapidConnectService, :count).by(-1)
        expect { rapid_connect_service.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'deletes the activation' do
        expect { run }.to change(Activation, :count).by(-1)
        expect { activation.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the service is missing from the response' do
      let(:service_list) { [] }

      it 'deletes the service' do
        expect { run }.to change(RapidConnectService, :count).by(-1)
        expect { rapid_connect_service.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context 'with a specific organization' do
    let!(:organizations) { create_list(:organization, 10).shuffle }
    let(:organization) { organizations.first }

    it 'associates the service with the organization' do
      run
      expect(RapidConnectService.last)
        .to have_attributes(organization: organization)
    end
  end

  context 'with an unknown organization' do
    let(:organization) { build(:organization) }

    it 'associates the service with no organization' do
      run
      expect(RapidConnectService.last)
        .to have_attributes(organization: nil)
    end
  end
end
