class ServiceCompatibilityReport < TabularReport
  report_type 'service-compatibility'
  header %w(Name Required Optional Compatible)
  footer

  def initialize(entity_id)
    @service_provider = ServiceProvider.find_by(entity_id: entity_id)
    title = @service_provider.name
    super(title)
  end

  def rows
    sorted_idps = identity_providers.sort_by do |idp|
      idp.name.downcase
    end

    sorted_idps.map do |idp|
      [idp.name, '2', '1', 'yes']
    end
  end

  private

  def identity_providers
    IdentityProvider.active
  end
end
