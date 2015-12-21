class IdentityProviderSessionsReport < TimeSeriesReport
  report_type 'identity-provider-sessions'

  y_label ''

  series sessions: 'Rate/h'

  units ''

  def initialize(entity_id, start, finish, steps)
    @identity_provider = IdentityProvider.find_by(entity_id: entity_id)
    title = "Identity Provider Sessions for #{@identity_provider.name}"

    super(title, start: start, end: finish)
    @start = start
    @finish = finish
    @steps = steps
  end

  private

  prepend Data::ReportData

  def range
    (0..(@finish - @start).to_i)
  end

  def data
    report = average_rate idp_sessions, @start, @steps.hours

    output_data range, report, @steps.hours, @steps
  end

  def idp_sessions
    DiscoveryServiceEvent.within_range(@start, @finish)
      .where(identity_provider: @identity_provider.id).sessions
  end
end
