# frozen_string_literal: true

# :nocov:
Sentry.init do |config|
  config.send_default_pii = true
  config.enabled_environments = [Rails.application.config.reporting_service[:url_options][:base_url]]
  config.environment = Rails.application.config.reporting_service[:url_options][:base_url]
  config.release = Rails.application.config.reporting_service[:version]
  config.logger = Logger.new(ENV.fetch('STDOUT', $stdout))
  config.logger.level = Logger::WARN
  config.include_local_variables = true
end
# :nocov:
