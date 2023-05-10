# frozen_string_literal: true

require 'mail'
require 'aws-sdk-sqs'
Rails.application.configure do
  mail_config = config.reporting_service[:mail]
  Mail.defaults { delivery_method :smtp, mail_config }

  if Rails.env.test?
    config.reporting_service.federationregistry[:host] = 'manager.example.edu'
    config.reporting_service.federationregistry[:secret] = 'abcdef'

    config.reporting_service.rapid_connect[:rack][:url] = 'https://rapid.example.com/jwt/authnrequest/research/0vs2aoAbd5bH6HRK'
    config.reporting_service.rapid_connect[:rack][:secret] = '5>O+`=2x%`\=.""f,6KDxV2p|MEE*P<]'
    config.reporting_service.rapid_connect[:rack][:issuer] = 'https://rapid.example.com'
    config.reporting_service.rapid_connect[:rack][:audience] = 'https://service.example.com'

    config.reporting_service.rapid_connect[:host] = 'rapid.example.edu'
    config.reporting_service.rapid_connect[:secret] = 'fedcba'

    config.reporting_service.sqs[:fake] = false
    config.reporting_service.sqs[:region] = 'dummy'
    config.reporting_service.sqs[:endpoint] = 'https://dummy.sqs.example.edu'
    config.reporting_service.sqs[:encryption_key] = 'spec/encryption_key.pem'
    config.reporting_service.sqs[:queues] = {
      discovery: 'https://dummy.sqs.example.edu/queue/discovery-service-test'
    }

    config.reporting_service.url_options[:base_url] = 'example.com'
    Aws.config.update(stub_responses: true)

    config.reporting_service.mail[:from] = 'noreply@example.com'
    config.reporting_service.environment_string = 'Test'

    Mail.defaults { delivery_method :test }
  end

  sqs_config = config.reporting_service[:sqs]
  if sqs_config[:fake]
    begin
      sqs_client = Aws::SQS::Client.new(region: sqs_config[:region],
                                        endpoint: sqs_config[:endpoint])

      sqs_config[:queues].each_value do |url|
        queue_name = url.split('/').last
        sqs_client.create_queue(queue_name: queue_name)
      end
    rescue StandardError
      :ok
    end
  end
end
