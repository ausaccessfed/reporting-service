# frozen_string_literal: true

max_threads_count = ENV.fetch('MAX_THREADS', 5)
min_threads_count = ENV.fetch('MIN_THREADS', max_threads_count)
threads min_threads_count, max_threads_count

worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

if ENV.fetch('RAILS_ENV', 'development') == 'production'
  ssl_bind '0.0.0.0', ENV.fetch('PORT', 3000), {
    key: ENV.fetch('KEY_PATH', '/run/secrets/tls.key'),
    cert: ENV.fetch('CERT_PATH', '/run/secrets/tls.crt'),
    verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
else
  port ENV.fetch('PORT', 3000)
end

log_requests true

# Specifies the `environment` that Puma will run in.
environment ENV.fetch('RAILS_ENV', 'development')

pidfile     ENV.fetch('PIDFILE', 'tmp/pids/server.pid')
# Ensure persistent timeout is greater than ALB, see
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#connection-idle-timeout
# https://github.com/ausaccessfed/federationmanager/pull/338/commits/ba66cbc57775d2fa88a0f9ff30e39f3c6f259688
persistent_timeout 75

unless ENV.fetch('STDOUT', nil).nil?
  stdout_redirect ENV.fetch('STDOUT', nil),
                  ENV.fetch('STDERR', nil),
                  :append
end

lowlevel_error_handler do |ex, env|
  Sentry.capture_exception(ex, extra: { puma: env })
  [500, {}, ['An error has occurred, and engineers have been informed. Please reload the page. ' \
             "If you continue to have problems, contact support@aaf.edu.au.\n"]]
end
