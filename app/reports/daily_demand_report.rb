# frozen_string_literal: true

class DailyDemandReport < TimeSeriesReport
  prepend ReportsSharedMethods

  report_type 'daily-demand'
  y_label 'Sessions / hour (average)'
  units ''
  series sessions: 'Sessions'

  def initialize(start, finish, source)
    title = 'Daily Demand'
    @start = start
    @finish = finish
    @source = source

    super(title, start: @start, end: @finish)
  end

  private

  def data
    daily_demand_output
  end
end
