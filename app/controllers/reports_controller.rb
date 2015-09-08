class ReportsController < ApplicationController
  def show
    public_action
    @start = 1.week.ago.utc.beginning_of_day
    @finish = Time.now.utc.beginning_of_day
    @data = RandomTimeSeriesReport.new('test', @start, @finish).generate
  end
end
