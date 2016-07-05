# frozen_string_literal: true
class ServiceProviderSourceIdentityProvidersReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'service-provider-source-identity-providers'
  header ['IdP Name', 'Total']
  footer

  def initialize(entity_id, start, finish)
    @service_provider = ServiceProvider.find_by(entity_id: entity_id)
    title = "SP Source Identity Providers Report for #{@service_provider.name}"
    create_time_instance_variables(start: start, finish: finish)

    super(title)
  end

  private

  def rows
    tabular_sessions(IdentityProvider, sp_sessions)
  end
end
