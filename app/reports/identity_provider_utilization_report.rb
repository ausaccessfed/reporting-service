class IdentityProviderUtilizationReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'identity-provider-utilization'

  header %w(Name Sessions)
  footer

  def initialize(start, finish)
    title = 'Identity Provider Utilization Report'
    @start = start
    @finish = finish

    super(title)
  end

  def rows
    utilization_sessions(:identity_provider)
  end
end