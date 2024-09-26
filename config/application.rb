# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails'
require 'dotenv/load' unless Rails.env.production?
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require_relative 'reporting_service_configuration'

Bundler.require(*Rails.groups)

module ReportingService
  class Application < Rails::Application
    config.autoload_paths += [
      File.join(config.root, 'lib'),
      File.join(config.root, 'app', 'reports'),
      File.join(config.root, 'app', 'jobs', 'concerns')
    ]

    config.autoloader = :zeitwerk

    config.assets.enabled = true
    config.assets.precompile += %w[render_report.js]

    # rubocop:disable Style/OpenStructUse
    config.reporting_service = OpenStruct.new(ReportingService::Configuration.build_configuration)
    # rubocop:enable Style/OpenStructUse

    if config.reporting_service.redis[:url].present?
      config.cache_store = [
        :redis_cache_store,
        {
          url: config.reporting_service.redis[:url],
          ssl_params: {
            verify_mode: OpenSSL::SSL::VERIFY_NONE
          },
          namespace: config.reporting_service.redis[:namespace],
          expires_in: 1.day
        }
      ]
      config.redis_client =
        Redis.new(
          url: Rails.application.config.reporting_service.redis[:url],
          ssl_params: {
            verify_mode: OpenSSL::SSL::VERIFY_NONE
          }
        )
    else
      config.cache_store = :redis_cache_store
      config.redis_client = Redis.new
    end

    if ENV['RAILS_LOG_TO_STDOUT'].present?
      logger = ActiveSupport::Logger.new(ENV.fetch('STDOUT', $stdout))
      logger.formatter = config.log_formatter
      config.logger = ActiveSupport::TaggedLogging.new(logger)
      config.lograge.enabled = true
      config.lograge.ignore_actions = %w[HealthController#show WelcomeController#index]
    end
  end
end

args = ['.aafimg', Lipstick::Images::Processor]
args << { silence_deprecation: true } if Sprockets::VERSION.start_with?('3')
Sprockets.register_engine(*args)
