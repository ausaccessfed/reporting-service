# frozen_string_literal: true

class RequestedAttributeReport < TabularReport
  report_type 'requested-attribute'
  header %w[Name Status]
  footer

  def initialize(name)
    title = "Service Providers requesting #{name}"
    super(title)
    @saml_attribute = SAMLAttribute.find_by(name:)
  end

  private

  def rows
    sorted_sps = service_providers.sort_by { |sp| sp.name.downcase }

    sorted_sps.map do |sp|
      status = attribute_status sp
      [sp.name, status]
    end
  end

  def service_providers
    ServiceProvider.active.preload(:service_provider_saml_attributes)
  end

  def attribute_status(sp)
    attribute_sp_joint = sp.service_provider_saml_attributes.detect { |o| o.saml_attribute_id == @saml_attribute.id }

    return 'none' unless attribute_sp_joint
    return 'optional' if attribute_sp_joint.optional?

    'required'
  end
end
