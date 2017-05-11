# frozen_string_literal: true

class IdentityProviderUtilizationReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'identity-provider-utilization'

  header %w[Name Sessions]
  footer

  def initialize(start, finish, source)
    title = 'Identity Provider Utilization Report'
    @start = start
    @finish = finish
    @source = source

    super(title)
  end

  def rows
    tabular_sessions(IdentityProvider)
  end
end
