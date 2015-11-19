class ProvidedAttributeReport < TabularReport
  report_type 'provided-attribute-report'
  header %w(Name Supported)
  footer

  def initialize(name)
    super(name)
    @name = name
  end

  def rows
    sorted_idps = identity_providers.sort_by do |idp|
      idp.name.downcase
    end

    sorted_idps.map do |idp|
      yes_or_no = supported idp
      [idp.name, yes_or_no]
    end
  end

  private

  def identity_providers
    IdentityProvider.preload(:saml_attributes)
  end

  def supported(idp)
    names = idp.saml_attributes.map(&:name)

    return 'yes' if names.include?(@name)
    'no'
  end
end
