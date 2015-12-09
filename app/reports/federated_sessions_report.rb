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
    ((@steps)..(@finish - @start)).step(@steps)
  end

  def data
    objects = DiscoveryServiceEvent
              .where('timestamp >= ? AND timestamp <= ? AND phase LIKE ?',
                     @start, @finish, 'response').pluck(:timestamp)

    increment = 0
    range.each_with_object(sessions: []) do |time, data|
      rate = average_rate time, increment, objects
      increment += @steps

      data[:sessions] << [increment, rate]
    end
  end

  def average_rate(time, increment, sessions)
    data = sessions.select do |s|
      (s >= @start + increment) && (s < @start + time)
    end

    (data.count.to_f / (@steps / 60)).round(1)
  end
end
