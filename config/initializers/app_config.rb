# frozen_string_literal: true

require 'mail'
require 'aws-sdk-sqs'

Rails.application.configure do
  app_config_file = Rails.root.join('config', 'reporting_service.yml')
  app_config = YAML.safe_load(app_config_file.read)
  config.reporting_service = Struct.new(app_config.deep_symbolize_keys)

  mail_config = config.reporting_service.mail
  Mail.defaults { delivery_method :smtp, mail_config }

  if Rails.env.test?
    config.reporting_service.ide = {
      host: 'ide.example.edu',
      cert: 'spec/api.crt',
      key: 'spec/api.key',
      admin_entitlements: ['urn:mace:aaf.edu.au:ide:internal:aaf-admin',
                           'urn:mace:aaf.edu.au:ide:internal:aaf-reporting'],
      federation_object_entitlement_prefix: 'urn:mace:aaf.edu.au:ide:internal'
    }

    config.reporting_service.federationregistry = {
      host: 'manager.example.edu',
      secret: 'abcdef'
    }

    config.reporting_service.rapidconnect = {
      host: 'rapid.example.edu',
      secret: 'fedcba'
    }

    config.reporting_service.sqs = {
      fake: false,
      region: 'dummy',
      endpoint: 'https://dummy.sqs.example.edu',
      encryption_key: 'spec/encryption_key.pem',
      queues: {
        discovery: 'https://dummy.sqs.example.edu/queue/discovery-service-test'
      }
    }

    config.reporting_service.url_options = { base_url: 'example.com' }
    Aws.config.update(stub_responses: true)

    config.reporting_service.mail = Struct.new(from: 'noreply@example.com')
    config.reporting_service.environment_string = 'Test'

    Mail.defaults { delivery_method :test }
  end

  sqs_config = config.reporting_service.sqs
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
