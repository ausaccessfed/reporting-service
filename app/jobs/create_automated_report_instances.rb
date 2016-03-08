class CreateAutomatedReportInstances
  def perform
    create_instances
  end

  private

  def create_instances
    select_reports.each do |report|
      start = range_start(report.interval)
      identifier = SecureRandom.urlsafe_base64

      AutomatedReportInstance
        .create_with(identifier: identifier)
        .find_or_create_by!(range_start: start,
                            automated_report: report)
    end
  end

  def select_reports
    [monthly, quarterly, yearly].compact.reduce(&:+)
  end

  def reports_with_intervals
    AutomatedReport.all.group_by(&:interval)
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
