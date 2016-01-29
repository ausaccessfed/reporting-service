class DailyDemandReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

  report_type 'daily-demand'
  y_label ''
  units ''
  series sessions: 'demand'

  def initialize(start, finish)
    title = 'Daily Demand'
    @start = start
    @finish = finish

    super(title, start: @start, end: @finish)
  end

  private

  def data
    daily_demand_output
  end
end
