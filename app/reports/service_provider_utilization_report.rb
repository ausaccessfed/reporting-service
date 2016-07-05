# frozen_string_literal: true
class ServiceProviderUtilizationReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'service-provider-utilization'

  header %w(Name Sessions)
  footer

  def initialize(start, finish)
    title = 'Service Provider Utilization Report'
    create_time_instance_variables(start: start, finish: finish)

    super(title)
  end

  def rows
    tabular_sessions(ServiceProvider)
  end
end
