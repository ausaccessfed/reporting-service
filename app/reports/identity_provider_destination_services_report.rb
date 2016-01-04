class IdentityProviderDestinationServicesReport < TabularReport
  report_type 'identity-provider-destination-services-report'
  header ['Name']
  footer

  def initialize(entity_id, start, finish)
    @identity_provider = IdentityProvider.find_by(entity_id: entity_id)
    title = "IdP Destination Report for #{@identity_provider.name}"
    @start = start
    @finish = finish

    super(title)
  end

  def rows
    [['']]
  end
end
