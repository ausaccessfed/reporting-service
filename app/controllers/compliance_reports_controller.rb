# frozen_string_literal: true

class ComplianceReportsController < ApplicationController
  def service_provider_compatibility_report
    public_action
    @objects_list = ServiceProvider.active
    @entity_id = params[:entity_id]

    return unless @entity_id

    report = ServiceCompatibilityReport.new(@entity_id)
    @data = JSON.generate(report.generate)
  end

  def identity_provider_attributes_report
    public_action
    @objects_list = IdentityProvider.active
    report = IdentityProviderAttributesReport.new
    @data = JSON.generate(report.generate)
  end

  def attribute_identity_providers_report
    public_action
    @name = params[:name]
    @objects_list = SAMLAttribute.all

    return unless @name

    report = ProvidedAttributeReport.new(@name)
    @data = JSON.generate(report.generate)
  end

  def attribute_service_providers_report
    public_action
    @name = params[:name]
    @objects_list = SAMLAttribute.all

    return unless @name

    report = RequestedAttributeReport.new(@name)
    @data = JSON.generate(report.generate)
  end
end
