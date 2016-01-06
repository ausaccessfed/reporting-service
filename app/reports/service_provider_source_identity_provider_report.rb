class ServiceProviderSourceIdentityProviderReport < TabularReport
  report_type 'service-provider-source-identity-providers'
  header ['IdP Name', 'Total']
  footer

  def initialize(entity_id, _start, _finish)
    @service_provider = ServiceProvider.find_by(entity_id: entity_id)
    title = "SP Source Identity Provider Report for #{@service_provider.name}"
    super(title)
  end

  private

  def rows
    [['', '']]
  end
end
