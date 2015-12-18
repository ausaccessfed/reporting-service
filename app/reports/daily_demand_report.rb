class DailyDemandReport < TimeSeriesReport
  report_type 'daily-demand'

  y_label ''

  series sessions: 'demand'

  units ''

  def initialize(start, finish)
    title = 'Daily Demand'

    super(title)
    @start = start.beginning_of_day
    @finish = finish.end_of_day
  end

  private

  def data
    sessions = DiscoveryServiceEvent
               .within_range(@start, @finish).pluck(:timestamp)

    report = demand_average_report sessions

    (0..86_340).step(1.minute).each_with_object(sessions: []) do |t, data|
      average = report[t] ? (report[t].to_f / days_count).round(1) : 0.0

      data[:sessions] << [t, average]
    end
  end

  def days_count
    (@start.to_i..@finish.to_i).step(1.day).count
  end

  def demand_average_report(sessions)
    sessions.each_with_object({}) do |session, data|
      t = (session - session.beginning_of_day).to_i
      point = t - t % 1.minute
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end
end
