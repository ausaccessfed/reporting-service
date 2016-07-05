# frozen_string_literal: true
class IdentityProviderDestinationServicesReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'identity-provider-destination-services'
  header ['SP Name', 'Total']
  footer

  def initialize(entity_id, start, finish)
    @identity_provider = IdentityProvider.find_by(entity_id: entity_id)
    title = "IdP Destination Report for #{@identity_provider.name}"
    create_time_instance_variables(start: start, finish: finish)

    super(title)
  end

  private

  def rows
    tabular_sessions(ServiceProvider, idp_sessions)
  end
end
