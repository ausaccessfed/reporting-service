# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails'
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

    config.assets.precompile += %w[render_report.js]

    config.active_record.logger = Logger.new($stderr) if ENV['AAF_DEBUG']

    config.reporting_service = ReportingService::Configuration.build_configuration.deep_symbolize_keys

    config.cache_store = :redis_store,
                         config.reporting_service[:redis][:url]
    { expire_in: 1.day }
  end
end

args = ['.aafimg', Lipstick::Images::Processor]
args << { silence_deprecation: true } if Sprockets::VERSION.start_with?('3')
Sprockets.register_engine(*args)
