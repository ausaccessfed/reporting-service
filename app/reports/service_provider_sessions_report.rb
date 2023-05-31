# frozen_string_literal: true

class ServiceProviderSessionsReport < TimeSeriesReport
  prepend ReportsSharedMethods

  report_type 'service-provider-sessions'
  y_label 'Sessions / hour (average)'
  units ''
  series sessions: 'Sessions'

  def initialize(entity_id, start, finish, steps, source)
    @service_provider = ServiceProvider.find_by(entity_id:)
    title = "Service Provider Sessions for #{@service_provider.name}"
    @start = start
    @finish = finish
    @steps = steps
    @source = source

    super(title, start: @start, end: @finish)
  end

  private

  def data
    per_hour_output sp_sessions
  end
end
