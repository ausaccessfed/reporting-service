class CreateAutomatedReportInstances
  def perform
    create_instances
  end

  private

  def automated_reports
    AutomatedReport
      .preload(:automated_report_subscriptions)
      .preload(:automated_report_instances)
      .select { |r| !r.automated_report_subscriptions.blank? }
  end

  def create_instances
    due_reports.each do |report|
      start = range_start(report.interval)

      AutomatedReportInstance
        .create!(automated_report: report,
                 identifier: SecureRandom.urlsafe_base64,
                 range_start: start)
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
    return unless [1, 4, 7, 10].include?(time.month)

    reports_with_intervals['quarterly']
  end

  def yearly
    return unless time.month == 1

    reports_with_intervals['yearly']
  end

  def time
    Time.zone.now
  end

  def range_start(interval)
    intervals = {
      'monthly' => 1,
      'quarterly' => 3,
      'yearly' => 12
    }.freeze

    (time - intervals[interval].months).beginning_of_month
  end
end
