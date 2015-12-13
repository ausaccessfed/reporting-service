class FederatedSessionsReport < TimeSeriesReport
  report_type 'federated-sessions'

  y_label ''

  series sessions: 'Rate/m'

  units ''

  def initialize(start, finish, steps)
    title = 'Federated Sessions'

    super(title, start, finish)
    @start = start
    @finish = finish
    @steps = steps.minutes.to_i
  end

  private

  def range
    (0..(@finish - @start).to_i).step(@steps)
  end

  def data
    sessions = DiscoveryServiceEvent
               .where('timestamp >= ? AND timestamp <= ? AND phase LIKE ?',
                      @start, @finish, 'response').pluck(:timestamp)

    report = average_rate sessions
    range.each_with_object(sessions: []) do |t, data|
      average = report[t] ? (report[t].to_f / (@steps / 60)).round(1) : 0.0
      data[:sessions] << [t, average]
    end
  end

  def average_rate(sessions)
    sessions.each_with_object({}) do |session, data|
      offset = session - @start
      point = offset - (offset % @steps)
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end
end
