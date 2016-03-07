class CreateAutomatedReportInstances
  def perform
    due_reports.each do |report|
      create_instance report
    end
  end

  private

  def automated_reports
    AutomatedReport
      .preload(:automated_report_subscriptions)
      .select { |r| !r.automated_report_subscriptions.blank? }
  end

  def create_instance(report)
    range_start = current_time.beginning_of_month
    interval = SecureRandom.urlsafe_base64

    AutomatedReportInstance
      .create!(automated_report: report,
               identifier: interval, range_start: range_start)
  end

  def due_reports
    [monthly, quarterly, yearly].compact.reduce(&:+)
  end

  def reports_with_intervals
    automated_reports.group_by(&:interval)
  end

  def monthly
    reports_with_intervals['monthly']
  end

  def quarterly
    return unless [1, 4, 7, 10].include?(current_time.month)

    reports_with_intervals['quarterly']
  end

  def yearly
    return unless current_time.month == 1

    reports_with_intervals['yearly']
  end

  def current_time
    Time.zone.now
  end
end
