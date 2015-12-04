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
    @steps = steps
  end

  private

  def range
    start = @start
    finish = @finish
    ((@steps.minutes.to_i)..(finish - start).to_i).step(@steps.minutes)
  end

  def data
    objects = DiscoveryServiceEvent
              .where('timestamp >= ? AND timestamp <= ? AND phase LIKE ?',
                     @start, @finish, 'response').pluck(:timestamp)

    index = 0
    range.each_with_object(sessions: []) do |time, data|
      rate = average_rate time, index, objects
      index = time + @steps.minutes
      data[:sessions] << [time, rate]
    end
  end

  def average_rate(time, index, sessions)
    data = sessions.select do |s|
      (s >= (@start + index)) && (s <= (@start + time))
    end

    (data.count / @steps).round(1)
  end
end
