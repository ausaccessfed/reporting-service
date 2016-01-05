class ServiceProviderSessionsReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

  report_type 'service-provider-sessions'

  y_label ''

  series sessions: 'Rate/h'

  units ''

  def initialize(entity_id, start, finish, steps)
    @service_provider = ServiceProvider.find_by(entity_id: entity_id)
    title = "Service Provider Sessions for #{@service_provider.name}"

    super(title, start: start, end: finish)
    @start = start
    @finish = finish
    @steps = steps
  end

  private

  def data
    per_hour_output sp_sessions
  end
end
