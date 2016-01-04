class IdentityProviderDailyDemandReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

  report_type 'identity-provider-daily-demand'

  y_label ''

  series sessions: 'demand'

  units ''

  def initialize(entity_id, start, finish)
    @identity_provider = IdentityProvider.find_by(entity_id: entity_id)
    title = "IdP Daily Demand Report for #{@identity_provider.name}"

    super(title)
    @start = start.beginning_of_day
    @finish = finish.end_of_day
  end

  private

  def data
    daily_demand_output idp_sessions
  end
end
