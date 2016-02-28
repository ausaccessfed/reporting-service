class ServiceProviderUtilizationReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'service-provider-utilization'

  header %w(Name Sessions)
  footer

  def initialize(start, finish)
    title = 'Service Provider Utilization Report'
    @start = start
    @finish = finish

    super(title)
  end

  def rows
    utilization_sessions(:service_provider)
  end
end
