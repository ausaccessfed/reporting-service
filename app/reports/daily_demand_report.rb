class DailyDemandReport < TimeSeriesReport
  report_type 'daily-demand'

  y_label ''

  series sessions: 'daily_demand'

  units ''

  def initialize(start, finish)
    title = 'Daily Demand'

    super(title)
    @start = start.beginning_of_day
    @finish = finish.end_of_day
    @days_count = (@finish - @start) / 86_400
  end

  private

  def data
    sessions = DiscoveryServiceEvent
               .where('timestamp >= ? AND timestamp <= ? AND phase LIKE ?',
                      @start, @finish, 'response').pluck(:timestamp)

    report = demand_average_report sessions

    (0..86_340).step(60).each_with_object(sessions: []) do |t, data|
      average = report[t] ? (report[t].to_f / @days_count).round(1) : 0.0

      data[:sessions] << [t, average]
    end
  end

  def demand_average_report(sessions)
    sessions.each_with_object({}) do |session, data|
      offset = session - @start
      increment = offset - offset % 86_400
      point = offset - (offset % 60) - increment.to_i
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end
end
