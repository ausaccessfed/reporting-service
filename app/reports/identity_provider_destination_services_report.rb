class IdentityProviderDestinationServicesReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'identity-provider-destination-services'
  header ['SP Name', 'Total']
  footer

  def initialize(entity_id, start, finish)
    @identity_provider = IdentityProvider.find_by(entity_id: entity_id)
    title = "IdP Destination Report for #{@identity_provider.name}"
    @start = start
    @finish = finish

    super(title)
  end

  private

  def rows
    tabular_sessions(:service_provider)
  end
end
