class RequestedAttributeReport < TabularReport
  report_type 'requested-attribute'
  header %w(Name Status)
  footer

  def initialize(name)
    title = "Service Providers requesting #{name}"
    super(title)
    @saml_attribute = SAMLAttribute.find_by(name: name)
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
    ServiceProvider.active
      .preload(:service_provider_saml_attributes)
  end

  def attribute_status(sp)
    attribute_sp_joint = sp.service_provider_saml_attributes
                         .detect { |o| o.saml_attribute == @saml_attribute }

    return 'none' unless attribute_sp_joint
    return 'optional' if attribute_sp_joint.optional?

    'required'
  end
end
