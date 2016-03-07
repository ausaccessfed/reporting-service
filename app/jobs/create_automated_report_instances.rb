class CreateAutomatedReportInstances
  def perform
    create_instance
  end

  private

  def automated_reports
    AutomatedReport
      .preload(:automated_report_subscriptions)
      .select { |r| !r.automated_report_subscriptions.blank? }
  end

  def create_instance
    automated_reports.each do |report|
      AutomatedReportInstance
        .create!(automated_report: report,
                 identifier: SecureRandom.urlsafe_base64,
                 range_start: current_time.beginning_of_month)
    end
  end

  def current_time
    Time.zone.now
  end
end
