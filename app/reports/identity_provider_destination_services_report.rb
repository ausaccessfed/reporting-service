class IdentityProviderDestinationServicesReport < TabularReport
  prepend TimeSeriesSharedMethods

  report_type 'identity-provider-destination-services'
  header ['IdP Name', 'Total']
  footer

  def initialize(entity_id, start, finish)
    @identity_provider = IdentityProvider.find_by(entity_id: entity_id)
    title = "IdP Destination Report for #{@identity_provider.name}"
    @start = start
    @finish = finish

    super(title)
  end

  def rows
    idp_sessions.group_by(&:service_provider)
      .map { |sp, val| [sp.name, val.count] }
  end
end
