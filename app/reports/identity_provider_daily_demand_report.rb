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
    @start = start
    @finish = finish
  end

  private

  def data
    report = daily_demand_average_rate idp_sessions

    output_data 0..86_340, report, 1.minute, days_count
  end
end
