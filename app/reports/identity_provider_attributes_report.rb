# frozen_string_literal: true

class IdentityProviderAttributesReport < TabularReport
  report_type 'identity-provider-attributes'
  header ['Name', 'Core Attributes', 'Optional Attributes']
  footer

  def initialize
    super('Identity Provider Attributes')
  end

  private

  def rows
    sorted_idps = active_identity_providers.sort_by { |idp| idp.name.downcase }

    sorted_idps.map do |idp|
      core_attributes, optional_attributes = idp.saml_attributes.partition(&:core?)

      [idp.name, core_attributes.count.to_s, optional_attributes.count.to_s]
    end
  end

  def active_identity_providers
    IdentityProvider.active.preload(:saml_attributes)
  end
end
