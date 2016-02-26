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
    report = utilization_report(:service_provider)
    report.sort_by { |r| r[0] }
  end
end
