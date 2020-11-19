# frozen_string_literal: true

class ReceiveEventsFromDiscoveryService
  def perform
    sqs_results.each do |result|
      result.messages.each do |message|
        process_message(message)

        sqs_client.delete_message(queue_url: queue_url,
                                  receipt_handle: message.receipt_handle)
      end
    end
  end

  private

  def sqs_results
    Enumerator.new do |y|
      loop do
        result = sqs_client.receive_message(queue_url: queue_url)
        break if result.messages.empty?

        y << result
      end
    end
  end

  def process_message(message)
    jwe = JSON::JWT.decode(message.body, key)
    data = JSON::JWT.decode(jwe.plain_text, key)
    DiscoveryServiceEvent.transaction do
      data['events'].each do |event|
        push_to_fr_queue(event)

        DiscoveryServiceEvent
          .create_with(event)
          .find_or_create_by(event.slice(:unique_id, :phase))
      end
    end
  end

  def push_to_fr_queue(event)
    return unless event[:phase] == 'response'

    redis.lpush('wayf_access_record', JSON.generate(event))
  end

  def sqs_client
    @sqs_client ||= Aws::SQS::Client.new(endpoint: sqs_config[:endpoint],
                                         region: sqs_config[:region])
  end

  def sqs_config
    Rails.application.config.reporting_service.sqs
  end

  def queue_url
    sqs_config[:queues][:discovery]
  end

  def key
    @key ||= OpenSSL::PKey::RSA.new(File.read(sqs_config[:encryption_key]))
  end

  def redis
    @redis ||= Redis.new
  end
end
