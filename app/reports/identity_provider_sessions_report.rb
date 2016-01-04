class IdentityProviderSessionsReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

  report_type 'identity-provider-sessions'

  y_label ''

  series sessions: 'Rate/h'

  units ''

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
    output_data idp_sessions
  end
end
