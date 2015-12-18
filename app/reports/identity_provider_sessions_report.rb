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

  def range
    (0..(@finish - @start).to_i).step(@steps.hours)
  end

  def data
    sessions = idp_sessions(@identity_provider.id)

    report = average_rate sessions
    range.each_with_object(sessions: []) do |t, data|
      average = report[t] ? (report[t].to_f / @steps).round(1) : 0.0
      data[:sessions] << [t, average]
    end
  end

  def average_rate(sessions)
    sessions.each_with_object({}) do |session, data|
      offset = session - @start
      point = offset - (offset % @steps.hours)
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end

  def idp_sessions(idp_id)
    query = 'identity_provider_id = ? AND timestamp >= ?'\
            'AND timestamp <= ? AND phase LIKE ?'

    DiscoveryServiceEvent
      .where(query, idp_id, @start, @finish, 'response').pluck(:timestamp)
  end
end
