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

  def service_provider_atrributes
    @service_provider.service_provider_saml_attributes
  end

  def report(idp)
    data = common_attributes idp
    report = Hash.new([]).merge(data)

    { required: report[false].count,
      optional: report[true].count, compatible: compatibility(idp) }
  end

  def common_attributes(idp)
    grouped_attributes.transform_values do |group|
      group.select do |attribute|
        idp.saml_attributes.any? do |idp_saml|
          idp_saml.id == attribute.saml_attribute_id
        end
      end
    end
  end

  def compatibility(idp)
    grouped_attributes[false].each do |reqired|
      return false unless idp.saml_attributes.any? do |a|
        a.id == reqired.saml_attribute_id
      end
    end

    true
  end

  def grouped_attributes
    Hash.new([]).merge(service_provider_atrributes
                       .group_by(&:optional))
  end
end
