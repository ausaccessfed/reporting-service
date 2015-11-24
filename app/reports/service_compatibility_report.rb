class ServiceCompatibilityReport < TabularReport
  report_type 'service-compatibility'
  header %w(Name Required Optional Compatible)
  footer

  def initialize(entity_id)
    @service_provider = ServiceProvider.find_by(entity_id: entity_id)
    title = "Service Compatibility for #{@service_provider.name}"
    super(title)
  end

  def rows
    sorted_idps = active_identity_providers.sort_by do |idp|
      idp.name.downcase
    end

    sorted_idps.map do |idp|
      attributes = report idp
      compatible = attributes[:compatible] ? 'yes' : 'no'

      [idp.name, attributes[:required].to_s,
       attributes[:optional].to_s, compatible]
    end
  end

  private

  def active_identity_providers
    IdentityProvider.active.preload(:saml_attributes)
  end

  def requested_atrributes
    @service_provider.service_provider_saml_attributes
  end

  def report(idp)
    idp_saml_attribute_ids = idp.saml_attributes.map(&:id)

    required_attributes = grouped_attributes[:required]
                          .map(&:saml_attribute_id) & idp_saml_attribute_ids
    optional_attributes = grouped_attributes[:optional]
                          .map(&:saml_attribute_id) & idp_saml_attribute_ids

    { required: required_attributes.count,
      optional: optional_attributes.count,
      compatible: compatibility(idp_saml_attribute_ids) }
  end

  def compatibility(idp_attribute_ids)
    required_ids = grouped_attributes[:required].map(&:saml_attribute_id)
    (required_ids & idp_attribute_ids).sort == required_ids.sort
  end

  def grouped_attributes
    optional, required = requested_atrributes.partition(&:optional)
    { optional: optional, required: required }
  end
end
