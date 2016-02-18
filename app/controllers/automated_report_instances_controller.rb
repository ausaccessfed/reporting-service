class AutomatedReportInstancesController < ApplicationController
  before_action :set_access_method

  def show
    @instance = instance
    report = generate_report
    @data = JSON.generate(report)
  end

  private

  def instance
    AutomatedReportInstance.find_by(identifier: params[:identifier])
  end

  def automated_report
    instance.automated_report
  end

  def interval
    automated_report.interval
  end

  def range_start
    instance.range_start
  end

  def generate_report
    args = [automated_report.target, *report_range, step_width].compact
    automated_report.report_class.constantize.new(*args).generate
  end

  def report_range
    return nil unless needs_range?

    n = 1
    n = 3 if interval.quarterly?
    n = 12 if interval.yearly?
    range_end = n.months.since(range_start)
    [range_start, range_end]
  end

  def step_width
    return nil unless needs_step_width?
    1
  end

  def needs_range?
    REPORTS_THAT_NEED_RANGE.include?(automated_report.report_class)
  end

  def needs_step_width?
    REPORTS_THAT_NEED_STEP_WIDTH.include?(automated_report.report_class)
  end

  REPORTS_THAT_NEED_RANGE = %w(
    DailyDemandReport
    FederationGrowthReport
    FederatedSessionsReport
    IdentityProviderDailyDemandReport
    IdentityProviderSessionsReport
    IdentityProviderDestinationServicesReport
    ServiceProviderDailyDemandReport
    ServiceProviderSessionsReport
    ServiceProviderSourceIdentityProvidersReport
  ).freeze

  REPORTS_THAT_NEED_STEP_WIDTH = %w(
    FederatedSessionsReport
    IdentityProviderSessionsReport
    ServiceProviderSessionsReport
  ).freeze

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
  private_constant :REPORTS_THAT_NEED_RANGE, :REPORTS_THAT_NEED_STEP_WIDTH
end
