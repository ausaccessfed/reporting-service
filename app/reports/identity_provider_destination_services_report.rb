# frozen_string_literal: true

class IdentityProviderDestinationServicesReport < TabularReport
  prepend ReportsSharedMethods

  report_type 'identity-provider-destination-services'
  header ['SP Name', 'Total']
  footer

  def initialize(entity_id, start, finish, source)
    @identity_provider = IdentityProvider.find_by(entity_id:)
    title = "IdP Destination Report for #{@identity_provider.name}"
    @start = start
    @finish = finish
    @source = source

    super(title)
  end

  private

  def rows
    tabular_sessions(ServiceProvider, idp_sessions)
  end
end
