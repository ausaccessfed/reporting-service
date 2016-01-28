class ReceiveEventsFromDiscoveryService
  def perform
    result = sqs_client.receive_message(queue_url: queue_url)
    result.messages.each do |message|
      process_message(message)

      sqs_client.delete_message(queue_url: queue_url,
                                receipt_handle: message.receipt_handle)
    end
  end

  private

  def process_message(message)
    jwe = JSON::JWT.decode(message.body, key)
    data = JSON::JWT.decode(jwe.plain_text, key)
    data['events'].each do |event|
      redis.lpush('wayf_access_record', JSON.generate(event))
      DiscoveryServiceEvent.create_with(event)
                           .find_or_create_by!(event.slice(:unique_id, :phase))
    end
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
