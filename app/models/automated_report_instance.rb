# frozen_string_literal: true

class AutomatedReportInstance < ActiveRecord::Base
  belongs_to :automated_report

  valhammer

  validate :time_must_be_utc_midnight
  validates :identifier, format: /\A[a-zA-Z0-9_-]+\z/

  delegate :interval, to: :automated_report

  def materialize
    args = [automated_report.target, *report_range, step_width].compact
    automated_report.report_class.constantize.new(*args)
  end

  private

  def time_must_be_utc_midnight
    t = range_end
    return if t.nil? || [t.gmt_offset, t.hour, t.min, t.sec].all?(&:zero?)

    errors.add(:range_end, 'must be midnight, UTC')
  end

  def report_range
    return nil unless needs_range?

    n = 1
    n = 3 if interval.quarterly?
    n = 12 if interval.yearly?

    range_start = range_end - n.months
    [range_start, range_end]
  end

  def step_width
    return nil unless needs_step_width?

    1
  end

  REPORTS_THAT_NEED_RANGE = %w[
    FederationGrowthReport DailyDemandReport FederatedSessionsReport
    IdentityProviderDailyDemandReport IdentityProviderDestinationServicesReport
    IdentityProviderSessionsReport
    ServiceProviderDailyDemandReport ServiceProviderSessionsReport
    ServiceProviderSourceIdentityProvidersReport
    IdentityProviderUtilizationReport ServiceProviderUtilizationReport
  ].freeze

  def needs_range?
    REPORTS_THAT_NEED_RANGE.include?(automated_report.report_class)
  end

  REPORTS_THAT_NEED_STEP_WIDTH = %w[
    FederatedSessionsReport IdentityProviderSessionsReport
    ServiceProviderSessionsReport
  ].freeze

  def needs_step_width?
    REPORTS_THAT_NEED_STEP_WIDTH.include?(automated_report.report_class)
  end

  private_constant :REPORTS_THAT_NEED_RANGE, :REPORTS_THAT_NEED_STEP_WIDTH
end
