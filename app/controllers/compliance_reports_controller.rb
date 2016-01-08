class ComplianceReportsController < ApplicationController
  def service_provider_compatibility_report
    public_action
    @service_providers = ServiceProvider.active
    @entity_id = params[:entity_id]

    return unless @entity_id

    report = ServiceCompatibilityReport.new(@entity_id)
    @data = JSON.generate(report.generate)
  end

  def identity_provider_attributes_report
    public_action
    @identity_providers = IdentityProvider.active
    report = IdentityProviderAttributesReport.new
    @data = JSON.generate(report.generate)
  end

  def attribute_identity_providers_report
    public_action
    @name = params[:name]
    @saml_attributes = SAMLAttribute.all

    return unless @name

    report = ProvidedAttributeReport.new(@name)
    @data = JSON.generate(report.generate)
  end
end
