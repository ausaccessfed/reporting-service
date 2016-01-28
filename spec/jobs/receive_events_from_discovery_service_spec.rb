require 'rails_helper'

RSpec.describe ReceiveEventsFromDiscoveryService, type: :job do
  describe '#perform' do
    let(:client) { double(Aws::SQS::Client) }
    let(:key) { OpenSSL::PKey::RSA.new(File.read('spec/encryption_key.pem')) }

    let(:sqs_config) do
      {
        fake: false,
        region: 'dummy',
        endpoint: Faker::Internet.url,
        encryption_key: 'spec/encryption_key.pem',
        queues: {
          discovery: Faker::Internet.url
        }
      }
    end

    before do
      allow(Rails.application.config.reporting_service).to receive(:sqs)
        .and_return(sqs_config)

      allow(Aws::SQS::Client).to receive(:new)
        .with(sqs_config.slice(:endpoint, :region))
        .and_return(client)
    end

    context 'when a message is in the queue' do
      let(:event_attrs) do
        FactoryGirl.attributes_for(:discovery_service_event)
      end

      let(:event) { event_attrs }

      let(:message_body) do
        JSON::JWT.new(iss: 'discovery-service', events: [event])
                 .sign(key, :RS256).encrypt(key).to_s
      end

      let(:receipt_handle) { SecureRandom.base64 }

      let(:messages) do
        [
          double(Aws::SQS::Types::Message,
                 receipt_handle: receipt_handle, body: message_body)
        ]
      end

      let(:receive_message_result) do
        double(Aws::SQS::Types::ReceiveMessageResult, messages: messages)
      end

      def run
        subject.perform
      end

      before do
        allow(client).to receive(:receive_message)
          .with(queue_url: sqs_config[:queues][:discovery])
          .and_return(receive_message_result)

        allow(client).to receive(:delete_message).with(any_args)
      end

      it 'creates the discovery service event' do
        expect { run }.to change(DiscoveryServiceEvent, :count).by(1)
        expect(DiscoveryServiceEvent.last).to have_attributes(event_attrs)
      end

      it 'removes the SQS message' do
        expect(client).to receive(:delete_message)
          .with(queue_url: sqs_config[:queues][:discovery],
                receipt_handle: receipt_handle)

        run
      end

      it 'writes the event to a secondary local queue' do
        redis = Redis.new
        expect { run }.to change { redis.llen('wayf_access_record') }.by(1)
      end

      context 'when the discovery service event already exists' do
        let!(:existing_event) { create(:discovery_service_event, event_attrs) }

        it 'does not create a new event' do
          expect { run }.not_to change(DiscoveryServiceEvent, :count)
        end
      end

      context 'when a request phase already exists' do
        let(:event_attrs) do
          attributes_for(:discovery_service_event, :response)
        end

        let!(:existing_event) do
          create(:discovery_service_event, event_attrs.merge(phase: 'request'))
        end

        it 'creates the response phase event' do
          expect { run }.to change(DiscoveryServiceEvent, :count).by(1)
          expect(DiscoveryServiceEvent.last).to have_attributes(event_attrs)
        end
      end

      context 'when a response phase already exists' do
        let(:event_attrs) do
          attributes_for(:discovery_service_event)
        end

        let!(:existing_event) do
          create(:discovery_service_event, event_attrs.merge(phase: 'response'))
        end

        it 'creates the request phase event' do
          expect { run }.to change(DiscoveryServiceEvent, :count).by(1)
          expect(DiscoveryServiceEvent.last).to have_attributes(event_attrs)
        end
      end
    end
  end
end
