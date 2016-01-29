class ServiceProviderDailyDemandReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

  report_type 'service-provider-daily-demand'
  y_label ''
  units ''
  series sessions: 'demand'

  def initialize(entity_id, start, finish)
    @service_provider = ServiceProvider.find_by(entity_id: entity_id)
    title = "SP Daily Demand Report for #{@service_provider.name}"

    super(title)
    @start = start.beginning_of_day
    @finish = finish.end_of_day
  end

  private

  def data
    daily_demand_output sp_sessions
  end
end
