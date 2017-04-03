# frozen_string_literal: true

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

    let(:empty_result) do
      double(Aws::SQS::Types::ReceiveMessageResult, messages: [])
    end

    def run
      subject.perform
    end

    context 'when the queue contains many SQS messages' do
      let(:events_attrs) do
        Array.new(5) { FactoryGirl.attributes_for(:discovery_service_event) }
      end

      let(:events) { events_attrs }

      let(:message_bodies) do
        events.map do |event|
          JSON::JWT.new(iss: 'discovery-service', events: [event])
                   .sign(key, :RS256).encrypt(key).to_s
        end
      end

      let(:receipt_handles) { message_bodies.map { SecureRandom.base64 } }

      let(:messages) do
        message_bodies.zip(receipt_handles).map do |(body, receipt_handle)|
          double(Aws::SQS::Types::Message,
                 receipt_handle: receipt_handle, body: body)
        end
      end

      let(:receive_message_results) do
        messages.map do |message|
          double(Aws::SQS::Types::ReceiveMessageResult, messages: [message])
        end
      end

      before do
        allow(client).to receive(:receive_message)
          .with(queue_url: sqs_config[:queues][:discovery])
          .and_return(*receive_message_results, empty_result)

        allow(client).to receive(:delete_message).with(any_args)
      end

      it 'creates the events' do
        expect { run }
          .to change(DiscoveryServiceEvent, :count).by(events.length)

        events_attrs.each do |attrs|
          expect(DiscoveryServiceEvent.find_by(attrs.slice(:unique_id)))
            .to have_attributes(attrs)
        end
      end

      context 'when an event is not able to be stored' do
        let(:events) do
          events_attrs.dup.unshift(timestamp: Time.zone.now)
        end

        it 'raises an exception' do
          expect { run }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
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

      before do
        allow(client).to receive(:receive_message)
          .with(queue_url: sqs_config[:queues][:discovery])
          .and_return(receive_message_result, empty_result)

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

      context 'when the event is a response' do
        let(:event_attrs) do
          FactoryGirl.attributes_for(:discovery_service_event, :response)
        end

        it 'writes the event to a secondary local queue' do
          redis = Redis.new
          expect { run }.to change { redis.llen('wayf_access_record') }.by(1)
        end
      end

      context 'when the event is a request' do
        let(:event_attrs) do
          FactoryGirl.attributes_for(:discovery_service_event, phase: 'request')
        end

        it 'does not write the event to the secondary queue' do
          redis = Redis.new
          expect { run }.not_to(change { redis.llen('wayf_access_record') })
        end
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
