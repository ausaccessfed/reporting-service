# frozen_string_literal: true

class IdentityProviderSessionsReport < TimeSeriesReport
  prepend ReportsSharedMethods

  report_type 'identity-provider-sessions'
  y_label 'Sessions / hour (average)'
  units ''
  series sessions: 'Sessions'

  def initialize(entity_id, start, finish, steps, source)
    @identity_provider = IdentityProvider.find_by(entity_id: entity_id)
    title = "Identity Provider Sessions for #{@identity_provider.name}"
    @start = start
    @finish = finish
    @steps = steps
    @source = source

    super(title, start: @start, end: @finish)
  end

  private

  def data
    per_hour_output idp_sessions
  end
end
