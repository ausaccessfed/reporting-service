class IdentityProviderAttributesReport < TabularReport
  report_type 'identity-provider-attributes'
  header ['Name', 'Core Attributes', 'Optional Attributes']
  footer

  def initialize
    super('Identity Provider Attributes')
  end

  def rows
    sorted_idps = activated_identitiy_providers.sort_by do |idp|
      idp.name.downcase
    end

    sorted_idps.map do |idp|
      optional_attributes = idp.saml_attributes.select { |a| !a.core? }
      core_attributes = idp.saml_attributes.select(&:core)

      [idp.name, "#{core_attributes.count}",
       "#{optional_attributes.count}"]
    end
  end

  private

  def activated_identitiy_providers
    IdentityProvider.active
      .joins(:saml_attributes).preload(:saml_attributes)
  end
end
