# frozen_string_literal: true

if !Rails.env.test? && ENV.fetch('PROMETHEUS_METRICS_SERVICE_HOST', '') != ''
  require 'prometheus_exporter/server'
  require 'prometheus_exporter/client'
  require 'prometheus_exporter/instrumentation'
  require 'prometheus_exporter/middleware'

  PrometheusExporter::Client.default =
    PrometheusExporter::Client.new(
      host: ENV.fetch('PROMETHEUS_METRICS_SERVICE_HOST', 'reporting-service-metrics.development.svc.cluster.local'),
      port: ENV.fetch('PROMETHEUS_METRICS_SERVICE_PORT', '9493').to_i,
      custom_labels: {
        hostname: PrometheusExporter.hostname,
        env: Rails.env,
        app: 'reporting-service',
        pod: ENV.fetch('HOSTNAME', 'unknown')
      }
    )

  PrometheusExporter::Client.default
  PrometheusExporter::Instrumentation::DelayedJob.register_plugin

  unless PrometheusExporter::Instrumentation::ActiveRecord.started?
    PrometheusExporter::Instrumentation::ActiveRecord.start(config_labels: %i[database])
  end

  # this reports basic process stats like RSS and GC info
  PrometheusExporter::Instrumentation::Process.start(type: ENV.fetch('PROMETHEUS_TYPE', 'server'))
  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware
end
