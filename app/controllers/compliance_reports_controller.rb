class ComplianceReportsController < ApplicationController
  def service_provider_compatibility_report
    public_action
    @service_providers = ServiceProvider.active.all
    @entity_id = params[:entity_id]
    return unless @entity_id

    report = ServiceCompatibilityReport.new(@entity_id)
    @data = JSON.generate(report.generate)
  end
end
