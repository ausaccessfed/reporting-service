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
      atrributes = common_attributes idp
      required_attributes_count = atrributes[false].count.to_s
      optional_attributes_count = atrributes[true].count.to_s

      [idp.name, required_attributes_count,
       optional_attributes_count, atrributes[:compatibility]]
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
    data = grouped_attributes.transform_values do |group|
      group.select do |g|
        idp.saml_attributes
        .any? { |saml| saml[:id] == g[:saml_attribute_id] }
      end
    end

    data[:compatibility] =
      compatibility_check(grouped_attributes[false], idp)

    Hash.new([]).merge(data)
  end

  def grouped_attributes
    Hash.new([]).merge(service_provider_atrributes.group_by(&:optional))
  end

  def compatibility_check(required_attributes, idp)
    required_attributes.each do |a|
      return 'no' unless idp.saml_attributes.any? do |o|
        o[:id] == a[:saml_attribute_id]
      end
    end

    'yes'
  end
end
