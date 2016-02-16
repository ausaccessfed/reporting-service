class ServiceProviderDailyDemandReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

  report_type 'service-provider-daily-demand'
  y_label 'Sessions / hour (average)'
  units ''
  series sessions: 'Sessions / h'

  def initialize(entity_id, start, finish)
    @service_provider = ServiceProvider.find_by(entity_id: entity_id)
    title = "SP Daily Demand Report for #{@service_provider.name}"
    @start = start
    @finish = finish

    super(title, start: @start, end: @finish)
  end

  private

  def data
    daily_demand_output sp_sessions
  end
end
