# frozen_string_literal: true

class IdentityProviderDailyDemandReport < TimeSeriesReport
  prepend ReportsSharedMethods

  report_type 'identity-provider-daily-demand'
  y_label 'Sessions / hour (average)'
  units ''
  series sessions: 'Sessions'

  def initialize(entity_id, start, finish, source)
    @identity_provider = IdentityProvider.find_by(entity_id: entity_id)
    title = "IdP Daily Demand Report for #{@identity_provider.name}"
    @start = start
    @finish = finish
    @source = source

    super(title, start: @start, end: @finish)
  end

  private

  def data
    daily_demand_output idp_sessions
  end
end
