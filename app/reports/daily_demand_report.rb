class DailyDemandReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

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
    daily_demand_output
  end
end
