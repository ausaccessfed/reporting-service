class DailyDemandReport < TimeSeriesReport
  include Data::ReportData

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
    output_data 0..86_340, 1.minute, days_count
  end

  def days_count
    (@start.to_i..@finish.to_i).step(1.day).count
  end

  def sessions
    DiscoveryServiceEvent.within_range(@start, @finish).sessions
  end

  def average_rate(sessions)
    sessions.each_with_object({}) do |session, data|
      offset = (session - session.beginning_of_day).to_i
      point = offset - offset % 1.minute
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end
end
