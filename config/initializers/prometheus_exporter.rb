# frozen_string_literal: true

unless Rails.env.test? && ENV.fetch('PROMETHEUS_METRICS_SERVICE_HOST', '') != '' # rubocop:disable Rails/EnvironmentVariableAccess
  require 'prometheus_exporter/server'
  require 'prometheus_exporter/client'
  require 'prometheus_exporter/instrumentation'
  require 'prometheus_exporter/middleware'

  PrometheusExporter::Client.default =
    PrometheusExporter::Client.new(
      host: ENV.fetch('PROMETHEUS_METRICS_SERVICE_HOST', 'reporting-service-metrics.development.svc.cluster.local'), # rubocop:disable Rails/EnvironmentVariableAccess
      port: ENV.fetch('PROMETHEUS_METRICS_SERVICE_PORT', '9493').to_i, # rubocop:disable Rails/EnvironmentVariableAccess
      custom_labels: {
        hostname: PrometheusExporter.hostname,
        env: Rails.env,
        app: 'reporting-service',
        pod: ENV.fetch('HOSTNAME', 'unknown') # rubocop:disable Rails/EnvironmentVariableAccess
      }
    )

  PrometheusExporter::Client.default
  PrometheusExporter::Instrumentation::DelayedJob.register_plugin

  unless PrometheusExporter::Instrumentation::ActiveRecord.started?
    PrometheusExporter::Instrumentation::ActiveRecord.start(config_labels: %i[database])
  end

  # this reports basic process stats like RSS and GC info
  PrometheusExporter::Instrumentation::Process.start(type: ENV.fetch('PROMETHEUS_TYPE', 'server')) # rubocop:disable Rails/EnvironmentVariableAccess
  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware
end
