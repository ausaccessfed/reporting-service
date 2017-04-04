# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module ReportingService
  class Application < Rails::Application
    config.autoload_paths += [
      File.join(config.root, 'lib'),
      File.join(config.root, 'app', 'reports'),
      File.join(config.root, 'app', 'jobs', 'concerns')
    ]

    config.assets.precompile += %w[render_report.js]

    config.rapid_rack.receiver = 'Authentication::SubjectReceiver'

    config.active_record.raise_in_transactional_callbacks = true

    config.active_record.logger = Logger.new($stderr) if ENV['AAF_DEBUG']

    config.cache_store = :redis_store,
                         'redis://127.0.0.1/0/reporting-service-cache',
                         { expire_in: 1.day }
  end
end

args = ['.aafimg', Lipstick::Images::Processor]
args << { silence_deprecation: true } if Sprockets::VERSION.start_with?('3')
Sprockets.register_engine(*args)
