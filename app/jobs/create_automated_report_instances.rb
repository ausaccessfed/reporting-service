class CreateAutomatedReportInstances
  def perform
    create_instances

    @generated_reports.each do |report|
      subs = report.automated_report_subscriptions
      send_email(subs)
    end
  end

  private

  def create_instances
    @generated_reports = []

    select_reports.each do |report|
      start = range_start(report.interval)

      next if instance_exists?(report, start)

      each_insatnce_create(report, start)
      @generated_reports += [report]
    end
  end

  def each_insatnce_create(report, start)
    AutomatedReportInstance
      .create!(identifier: SecureRandom.urlsafe_base64,
               automated_report: report,
               range_start: start)
  end

  def instance_exists?(report, start)
    AutomatedReportInstance.find_by(range_start: start,
                                    automated_report: report)
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

  def send_email(subscriptions)
    subscriptions.each do |subscription|
      Mail.deliver(to: subscription.subject.mail,
                   from: Rails.application.config
                              .reporting_service.mail[:from],
                   subject: 'AAF Reporting Service - New Report Generated',
                   body: 'TODO',
                   content_type: 'text/html; charset=UTF-8')
    end
  end
end
