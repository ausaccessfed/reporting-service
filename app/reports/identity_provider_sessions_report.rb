class IdentityProviderSessionsReport < TimeSeriesReport
  prepend Data::ReportData

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

  def range
    (0..(@finish - @start).to_i)
  end

  def data
    output_data range, @steps.hours, @steps
  end

  def average_rate(sessions)
    sessions.each_with_object({}) do |session, data|
      offset = session - @start
      point = offset - (offset % @steps.hours)
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end

  def sessions
    DiscoveryServiceEvent
      .within_range(@start, @finish)
      .where(identity_provider: @identity_provider.id).sessions
  end
end
