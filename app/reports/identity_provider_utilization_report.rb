# frozen_string_literal: true
class IdentityProviderUtilizationReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'identity-provider-utilization'

  header %w(Name Sessions)
  footer

  def initialize(start, finish)
    title = 'Identity Provider Utilization Report'
    create_time_instance_variables(start, finish)

    super(title)
  end

  def rows
    tabular_sessions(IdentityProvider)
  end
end
