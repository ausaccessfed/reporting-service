class CreateAutomatedReportInstances
  def perform
    create_instances
  end

  private

  def automated_reports
    AutomatedReport
      .preload(:automated_report_subscriptions)
      .select { |r| !r.automated_report_subscriptions.blank? }
  end

  def create_instances
    due_reports.each do |report|
      AutomatedReportInstance
        .create!(automated_report: report,
                 identifier: SecureRandom.urlsafe_base64,
                 range_start: current.beginning_of_month)
    end
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
    return unless [1, 4, 7, 10].include?(current.month)

    reports_with_intervals['quarterly']
  end

  def yearly
    return unless current.month == 1

    reports_with_intervals['yearly']
  end

  def current
    Time.zone.now
  end
end
