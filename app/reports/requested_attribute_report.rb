class RequestedAttributeReport < TabularReport
  report_type 'requested-attribute'
  header %w(Name Status)
  footer

  def initialize(name)
    title = "Service Providers requesting #{name}"
    super(title)
  end

  def rows
    sorted_sps = service_providers.sort_by do |sp|
      sp.name.downcase
    end

    sorted_sps.map do |sp|
      [sp.name, 'none']
    end
  end

  private

  def service_providers
    ServiceProvider.active.preload(:saml_attributes)
  end
end
