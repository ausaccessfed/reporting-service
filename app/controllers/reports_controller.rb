class ReportsController < ApplicationController
  def show
    public_action
    @data = RandomTimeSeriesReport
            .new('test', 1.week.ago.utc.beginning_of_day, Time.now.utc.beginning_of_day)
            .generate
  end
end
