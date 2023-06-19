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

  # Puma raises this error when a client makes a malformed HTTP request. It responds appropriately with 400 Bad Request.
  # We don't need to hear about that!
  # See https://github.com/getsentry/sentry-ruby/pull/2026#issuecomment-1525031744.
  config.excluded_exceptions << 'Puma::HttpParserError'
end
# :nocov:
