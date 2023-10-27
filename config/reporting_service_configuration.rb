# frozen_string_literal: true

module ReportingService
  module Configuration
    module_function

    def build_configuration
      ConfigurationGenerator.new.build_configuration.deep_symbolize_keys
    end
  end

    class ConfigurationGenerator
    def build_configuration
      base_config.merge(admins_config, redis, federation_registry, rapid_connect)
    end

    private

    def base_config
      {
        version:,
        discovery_service_hostname: ENV.fetch('DISCOVERY_SERVICE_HOSTNAME', 'ds.test.aaf.edu.au'),
        sqs: {
          fake: ENV.fetch('SQS_FAKE', false),
          region: ENV.fetch('SQS_REGION', 'localhost'),
          endpoint: ENV.fetch('SQS_ENDPOINT', 'http://localhost:9324'),
          encryption_key: ENV.fetch('SQS_DS_EVENT_ENCRYPTION_KEY', ''),
          queues: {
            discovery: ENV.fetch('SQS_DS_EVENT_QUEUE', 'http://localhost:9324/queue/discovery-service-development')
          }
        },
        ide: {
          admin_entitlements: %w[
            urn:mace:aaf.edu.au:ide:internal:aaf-admin
            urn:mace:aaf.edu.au:ide:internal:aaf-reporting
          ],
          federation_object_entitlement_prefix: 'urn:mace:aaf.edu.au:ide:internal'
        },
        default_session_source: ENV.fetch('DEFAULT_SESSION_SOURCE', 'DS'),
        mail: {
          from: ENV.fetch('EMAIL_FROM', 'noreply@example.com'),
          port: ENV.fetch('EMAIL_PORT', 1025).to_i,
          address: ENV.fetch('EMAIL_HOST', 'localhost')
        },
        environment_string: ENV.fetch('ENVIRONMENT_NAME', 'Test'),
        url_options: {
          base_url: ENV.fetch('BASE_URL', 'http://localhost:8082')
        },
        time_zone: ENV.fetch('TIME_ZONE', 'Australia/Brisbane')
      }
    end

    def rapid_connect_rack
      authenticator = 'RapidRack::Authenticator'

      ## TODO this doesnt exist use rapid.test russels rapid_connect_service
      # authenticator = 'RapidRack::MockAuthenticator' if Rails.env.development?
      authenticator = 'RapidRack::TestAuthenticator' if Rails.env.test?

      {
        url:
          ENV.fetch(
            'RAPID_CONNECT_RACK_URL',
            'https://rapid.test.aaf.edu.au/jwt/authnrequest/auresearch/29MDwRXGUEY5fVOM'
          ),
        secret: ENV.fetch('RAPID_CONNECT_RACK_SECRET', 'hL9NM4Y8Q6RU85//b8xJ325yL1D5kzanTMX9IrNygQm'),
        issuer: ENV.fetch('RAPID_CONNECT_RACK_ISSUER', 'https://rapid.test.aaf.edu.au'),
        audience: ENV.fetch('RAPID_CONNECT_RACK_AUDIENCE', 'http://localhost:8082'),
        authenticator:,
        receiver: 'Authentication::SubjectReceiver',
        error_handler: nil
      }
    end

    def federation_registry
      {
        federation_registry: {
          enable_sync: ENV.fetch('FEDERATION_REGISTRY_ENABLE_SYNC', 'true') == 'true',
          host: ENV.fetch('FEDERATION_REGISTRY_HOST', 'manager.test.aaf.edu.au'),
          secret:
            ENV.fetch(
              'FEDERATION_REGISTRY_SECRET',
              'This is the shared secret used for authenticating to the FR export API'
            ),
          database: {
            name: ENV.fetch('FEDERATION_REGISTRY_DB_NAME', ''),
            username: ENV.fetch('FEDERATION_REGISTRY_DB_USERNAME', ''),
            password: ENV.fetch('FEDERATION_REGISTRY_DB_PASSWORD', ''),
            host: ENV.fetch('FEDERATION_REGISTRY_DB_HOST', ''),
            port: ENV.fetch('FEDERATION_REGISTRY_DB_PORT', '3306')
          }
        }
      }
    end

    def rapid_connect
      {
        rapid_connect: {
          host: ENV.fetch('RAPID_CONNECT_HOST', 'rapid.test.aaf.edu.au'),
          secret:
            ENV.fetch(
              'RAPID_CONNECT_SECRET',
              'This is the shared secret used for authenticating to the Rapid export API'
            ),
          rack: rapid_connect_rack
        }
      }
    end

    def redis
      redis_url =
        if ENV.fetch('REDIS_AUTH_TOKEN', nil).present?
          "#{ENV.fetch('REDIS_SCHEME', 'redis')}://:#{CGI.escape(ENV.fetch('REDIS_AUTH_TOKEN', 'password'))}@" \
            "#{ENV.fetch('REDIS_HOST', 'localhost')}:6379/0"
        else
          ## TODO remove once live (legacy)
          ENV.fetch('REDIS_URL', 'redis://127.0.0.1/0/reporting-service-cache')
        end
      { redis: { url: redis_url, namespace: ENV.fetch('REDIS_NAMESPACE', 'reporting-service') } }
    end

    def version
      ENV.fetch('RELEASE_VERSION', '0.0.0-X-git_hash')
    end

    def admins_config
      if ENV.fetch('ADMIN_TOKENS', nil).present?
        # key//value,key2//value2 -> {key => [value],key2 => [value2]}
        return(
          {
            admins:
              ENV
                .fetch('ADMIN_TOKENS')
                .split(',')
                .each_with_object({}) do |pair, memo|
                  k, v = pair.split('//')
                  memo[k] = [v]
                end
          }
        )
      end
      {
        admins: {
          'shared_token_value' => ['urn:mace:aaf.edu.au:ide:internal:aaf-admin'],
          'shared_token_value2' => ['urn:mace:aaf.edu.au:ide:internal:aaf-admin']
        }
      }
    end
  end
  private_constant :ConfigurationGenerator
end
