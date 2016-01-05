class IdentityProviderSessionsReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

  report_type 'identity-provider-sessions'
  y_label ''
  units ''
  series sessions: 'Rate/h'

  def initialize(entity_id, start, finish, steps)
    @identity_provider = IdentityProvider.find_by(entity_id: entity_id)
    title = "Identity Provider Sessions for #{@identity_provider.name}"

    super(title, start: start, end: finish)
    @start = start
    @finish = finish
    @steps = steps
  end

  private

  def data
    per_hour_output idp_sessions
  end
end
