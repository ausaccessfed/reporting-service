class ServiceProviderSourceIdentityProviderReport < TabularReport
  prepend TimeSeriesSharedMethods

  report_type 'service-provider-source-identity-providers'
  header ['IdP Name', 'Total']
  footer

  def initialize(entity_id, start, finish)
    @service_provider = ServiceProvider.find_by(entity_id: entity_id)
    title = "SP Source Identity Provider Report for #{@service_provider.name}"
    @start = start
    @finish = finish

    super(title)
  end

  private

  def rows
    sp_sessions.preload(:identity_provider)
      .group_by(&:identity_provider)
      .map { |idp, val| [idp.name, val.count.to_s] }
  end
end
