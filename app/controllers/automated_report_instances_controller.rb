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

  def automated_report
    instance.automated_report
  end

  SUBSCRIBER_REPORTS = {
    'IdentityProviderSessionsReport' => IdentityProvider,
    'IdentityProviderDailyDemandReport' => IdentityProvider,
    'IdentityProviderDestinationServicesReport' => IdentityProvider,
    'ServiceProviderSessionsReport' => ServiceProvider,
    'ServiceProviderDailyDemandReport' => ServiceProvider,
    'ServiceProviderSourceIdentityProvidersReport' => ServiceProvider
  }.freeze

  def needs_subscriber_access?
    SUBSCRIBER_REPORTS.keys.include?(automated_report.report_class.to_s)
  end

  def needs_admin_access?
    automated_report.report_class.eql? 'SubscriberRegistrationsReport'
  end

  def entity
    target = automated_report.target
    entity_model = SUBSCRIBER_REPORTS[automated_report.report_class]

    entity_model.find_by(entity_id: target)
  end

  def permission_string
    "objects:organization:#{entity.organization.identifier}:report"
  end

  def set_access_method
    return check_access!('admin:*') if needs_admin_access?
    return check_access!('admin:*') if subject.permits?('admin:*')
    return check_access!(permission_string) if needs_subscriber_access?

    public_action
  end

  private_constant :SUBSCRIBER_REPORTS
end
