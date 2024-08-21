# frozen_string_literal: true

max_threads_count = ENV.fetch('MAX_THREADS', 5)
min_threads_count = ENV.fetch('MIN_THREADS', max_threads_count)
threads min_threads_count, max_threads_count

worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

if ENV.fetch('RAILS_ENV', 'development') == 'production'
  ssl_bind '0.0.0.0',
           ENV.fetch('PORT', 3000),
           {
             key: ENV.fetch('KEY_PATH', '/run/secrets/tls.key'),
             cert: ENV.fetch('CERT_PATH', '/run/secrets/tls.crt'),
             verify_mode: 'none'
           }
else
  port ENV.fetch('PORT', 3000)
end

# Specifies the `environment` that Puma will run in.
environment ENV.fetch('RAILS_ENV', 'development')

pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')
# Ensure persistent timeout is greater than ALB, see
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#connection-idle-timeout
# https://github.com/ausaccessfed/federationmanager/pull/338/commits/ba66cbc57775d2fa88a0f9ff30e39f3c6f259688
persistent_timeout 75

stdout_redirect ENV.fetch('STDOUT', nil), ENV.fetch('STDERR', nil), :append unless ENV.fetch('STDOUT', nil).nil?

lowlevel_error_handler do |ex, env|
  Sentry.capture_exception(ex, extra: { puma: env })
  [
    500,
    {},
    [
      'An error has occurred, and engineers have been informed. Please reload the page. ' \
        "If you continue to have problems, contact support@aaf.edu.au.\n"
    ]
  ]
end

if ENV.fetch('PROMETHEUS_METRICS_SERVICE_HOST', '') != ''
  on_booted { PrometheusExporter::Instrumentation::Puma.start(frequency: 1) }

  after_worker_boot do
    # if this is started outside after_worker_boot, then some metrics disappear
    unless PrometheusExporter::Instrumentation::Puma.started?
      PrometheusExporter::Instrumentation::Puma.start(frequency: 1)
    end
  end
end
