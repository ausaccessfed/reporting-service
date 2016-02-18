class AutomatedReportInstancesController < ApplicationController
  before_action :set_access_method

  def show
    @instance = instance
    report = @instance.materialize.generate
    @data = JSON.generate(report)
  end

  private

  def instance
    AutomatedReportInstance.find_by(identifier: params[:identifier])
  end

  def report_class
    instance.automated_report.report_class
  end

  SUBSCRIBER_REPORTS = {
    'IdentityProviderSessionsReport' => IdentityProvider,
    'IdentityProviderDailyDemandReport' => IdentityProvider,
    'IdentityProviderDestinationServicesReport' => IdentityProvider,
    'ServiceProviderSessionsReport' => ServiceProvider,
    'ServiceProviderDailyDemandReport' => ServiceProvider,
    'ServiceProviderSourceIdentityProvidersReport' => ServiceProvider
  }.freeze

  PUBLIC_REPORTS = %w(
    DailyDemandReport
    FederatedSessionsReport
    FederationGrowthReport
    IdentityProviderAttributesReport
    ProvidedAttributeReport
    RequestedAttributeReport
    ServiceCompatibilityReport
  ).freeze

  def public_report
    PUBLIC_REPORTS.include?(report_class)
  end

  def subscriber_report
    SUBSCRIBER_REPORTS.include?(report_class)
  end

  def entity
    target = instance.automated_report.target
    entity_model = SUBSCRIBER_REPORTS[report_class]

    entity_model.find_by(entity_id: target)
  end

  def subscriber_permissions
    "objects:organization:#{entity.organization.identifier}:report"
  end

  def set_access_method
    return public_action if public_report
    return check_access!(subscriber_permissions) if subscriber_report

    check_access! 'admin:*'
  end

  private_constant :SUBSCRIBER_REPORTS, :PUBLIC_REPORTS
end
