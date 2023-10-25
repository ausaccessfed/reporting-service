# frozen_string_literal: true

class ProvidedAttributeReport < TabularReport
  report_type 'provided-attribute'
  header %w[Name Supported]
  footer

  def initialize(name)
    title = "Identity Providers supporting #{name}"
    super(title)
    @name = name
  end

  private

  def rows
    sorted_idps = identity_providers.sort_by { |idp| idp.name.downcase }

    sorted_idps.map do |idp|
      yes_or_no = supported idp
      [idp.name, yes_or_no]
    end
  end

  def identity_providers
    IdentityProvider.active.preload(:saml_attributes)
  end

  def supported(idp)
    names = idp.saml_attributes.map(&:name)

    return 'yes' if names.include?(@name)

    'no'
  end
end
