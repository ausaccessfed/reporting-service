require File.expand_path('../boot', __FILE__)

require "rails"
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module ReportingService
  class Application < Rails::Application
    config.autoload_paths << File.join(config.root, 'lib')

    config.rapid_rack.receiver = 'Authentication::SubjectReceiver'

    config.active_record.raise_in_transactional_callbacks = true
  end
end
