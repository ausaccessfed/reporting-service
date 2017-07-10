# frozen_string_literal: true

class ServiceProviderUtilizationReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'service-provider-utilization'

  header %w[Name Sessions]
  footer

  def initialize(start, finish, source)
    title = 'Service Provider Utilization Report'
    @start = start
    @finish = finish
    @source = source

    super(title)
  end

  def rows
    tabular_sessions(ServiceProvider)
  end
end
