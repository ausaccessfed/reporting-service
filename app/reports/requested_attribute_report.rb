class RequestedAttributeReport < TabularReport
  report_type 'requested-attribute'
  header %w(Name Status)
  footer

  def initialize(name)
    title = "Service Providers requesting #{name}"
    super(title)
    @name = name
    @saml_attribute = SAMLAttribute.find_by(name: @name)
  end

  def rows
    sorted_sps = service_providers.sort_by do |sp|
      sp.name.downcase
    end

    sorted_sps.map do |sp|
      status = attribute_status sp
      [sp.name, status]
    end
  end

  private

  def service_providers
    ServiceProvider.active.preload(:saml_attributes)
  end

  def attribute_status(sp)
    names = sp.saml_attributes.map(&:name)
    return 'none' unless names.include?(@name)

    joint = ServiceProviderSAMLAttribute
            .service_provider_attribute_joint sp, @saml_attribute

    return 'optional' if joint.optional?
  end
end
