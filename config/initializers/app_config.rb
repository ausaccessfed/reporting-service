# frozen_string_literal: true

require 'mail'
require 'aws-sdk-sqs'
Rails.application.configure do
  mail_config = config.reporting_service[:mail]
  Mail.defaults { delivery_method :smtp, mail_config }

  if Rails.env.test?
    config.reporting_service.federation_registry[:host] = 'manager.example.edu'
    config.reporting_service.federation_registry[:secret] = 'abcdef'

    config.reporting_service.rapid_connect[:rack][:url] = 'https://rapid.example.com/jwt/authnrequest/research/0vs2aoAbd5bH6HRK'
    config.reporting_service.rapid_connect[:rack][:secret] = '5>O+`=2x%`\=.""f,6KDxV2p|MEE*P<]'
    config.reporting_service.rapid_connect[:rack][:issuer] = 'https://rapid.example.com'
    config.reporting_service.rapid_connect[:rack][:audience] = 'https://service.example.com'

    config.reporting_service.rapid_connect[:host] = 'rapid.example.edu'
    config.reporting_service.rapid_connect[:secret] = 'fedcba'
    config.reporting_service.version = 'VERSION_PROVIDED_ON_BUILD'

    config.reporting_service.sqs[:fake] = false
    config.reporting_service.sqs[:region] = 'dummy'
    config.reporting_service.sqs[:endpoint] = 'https://dummy.sqs.example.edu'
    rsa_key_string = <<~RAWCERT
      -----BEGIN RSA PRIVATE KEY-----
      MIIBOwIBAAJBANXI+YMTbremHgVLuc/AbaZTKeqvXgs32Em6OOCbE7P+flb3qAMO
      t2SgUCSFYZAOGk8SUoO3ffj6n30cfRA/weUCAwEAAQJAJ+eYs1/INd17Ew/8ggvw
      K7CwTU8opb1p0PFCtqIbvmf2QkljOnT9AvC9HXEi+f3soy2Nas8u0x9DfV2AStl4
      YQIhAO3LMGvPvLqLq/1gg9smR7RnjhcIMoP5RkOjMhXry4jpAiEA5ic14uiAb5If
      KOMObaIHYlg5sufDIy1CwRU5Exz3k50CIQDhRL0RVVIAEvMS7Mzc3i3NnNCBxzU7
      yvkieEapd6BwiQIhAMkHns3f/690lrsD+OpSCNkh7uQSBCSJuDEm9H95YdcRAiBY
      GGUfLfsFNdNhxp69xipHXoL6od4h/fWWrjZhu1/aiQ==
      -----END RSA PRIVATE KEY-----
    RAWCERT
    config.reporting_service.sqs[:encryption_key] = Base64.encode64(rsa_key_string)

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
        sqs_client.create_queue(queue_name:)
      end
    rescue StandardError
      :ok
    end
  end
end
