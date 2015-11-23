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
    sorted_idps = active_identity_providers.sort_by do |idp|
      idp.name.downcase
    end

    sorted_idps.map do |idp|
      required = common_attributes idp
      optional = common_attributes idp

      [idp.name, required[false].count.to_s,
       optional[true].count.to_s, 'no']
    end
  end

  private

  def active_identity_providers
    IdentityProvider.active.preload(:saml_attributes)
  end

  def service_provider_atrributes
    @service_provider.service_provider_saml_attributes
  end

  def common_attributes(idp)
    atrributes = service_provider_atrributes
                 .group_by(&:optional).transform_values do |group|
      group.select do |g|
        idp.saml_attributes.any? { |saml| saml.id == g.saml_attribute_id }
      end
    end

    Hash.new([]).merge(atrributes)
  end
end
