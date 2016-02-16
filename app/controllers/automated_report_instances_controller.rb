class AutomatedReportInstancesController < ApplicationController
  before_action :set_instance
  before_action { public_action }

  def show
    report = generate_report
    @data = JSON.generate(report)
  end

  private

  def set_instance
    @instance = AutomatedReportInstance
                .find_by(identifier: params[:identifier])
  end

  def automated_report
    @instance.automated_report
  end

  def interval
    automated_report.interval
  end

  def range_start
    @instance.range_start
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

  REPORTS_THAT_NEED_RANGE = %w(
    FederationGrowthReport DailyDemandReport FederatedSessionsReport
    IdentityProviderDailyDemandReport IdentityProviderDestinationServicesReport
    IdentityProviderSessionsReport
    ServiceProviderDailyDemandReport ServiceProviderSessionsReport
    ServiceProviderSourceIdentityProvidersReport
  ).freeze

  REPORTS_THAT_NEED_STEP_WIDTH = %w(
    FederatedSessionsReport IdentityProviderSessionsReport
    ServiceProviderSessionsReport
  ).freeze

  def needs_step_width?
    REPORTS_THAT_NEED_STEP_WIDTH.include?(automated_report.report_class)
  end

  private_constant :REPORTS_THAT_NEED_RANGE, :REPORTS_THAT_NEED_STEP_WIDTH
end
