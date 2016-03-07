class CreateAutomatedReportInstances
  def perform
    create_instances
  end

  private

  def create_instances
    due_reports.each do |report|
      start = range_start(report.interval)
      identifier = SecureRandom.urlsafe_base64

      AutomatedReportInstance
        .create!(automated_report: report,
                 identifier: identifier,
                 range_start: start)
    end
  end

  def automated_reports
    AutomatedReport.preload(:automated_report_instances)
  end

  def due_reports
    select_reports.select do |report|
      interval = report.interval
      instances = instances_range_starts(report)

      !instances.include? range_start(interval)
    end
  end

  def select_reports
    [monthly, quarterly, yearly].compact.reduce(&:+)
  end

  def instances_range_starts(report)
    report.automated_report_instances.pluck(:range_start)
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

    start_time = time - intervals[interval].months
    start_time.beginning_of_month
  end
end
