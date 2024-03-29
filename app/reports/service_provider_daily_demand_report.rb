# frozen_string_literal: true

class ServiceProviderDailyDemandReport < TimeSeriesReport
  prepend ReportsSharedMethods

  report_type 'service-provider-daily-demand'
  y_label 'Sessions / hour (average)'
  units ''
  series sessions: 'Sessions'

  def initialize(entity_id, start, finish, source)
    @service_provider = ServiceProvider.find_by(entity_id:)
    title = "SP Daily Demand Report for #{@service_provider.name}"
    @start = start
    @finish = finish
    @source = source

    super(title, start: @start, end: @finish)
  end

  private

  def data
    daily_demand_output sp_sessions
  end
end
