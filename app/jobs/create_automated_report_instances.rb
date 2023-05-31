# frozen_string_literal: true

class CreateAutomatedReportInstances
  include Rails.application.routes.url_helpers

  def initialize
    @base_url = Rails.application.config
                     .reporting_service.url_options[:base_url]
  end

  def perform
    report_instances.compact.each do |instance|
      report = instance.automated_report
      send_email(report, instance.identifier)
    end
  end

  private

  def report_instances
    AutomatedReportInstance.transaction do
      select_reports.flat_map do |report|
        perform_create(report)
      end
    end
  end

  def perform_create(report)
    report.update!(instances_timestamp: range_end)

    AutomatedReportInstance
      .create!(identifier: SecureRandom.urlsafe_base64,
               automated_report: report, range_end:)
  end

  def select_reports
    [monthly, quarterly, yearly].compact.reduce([], &:+)
  end

  def reports_with_intervals
    reports = AutomatedReport.preload(:automated_report_subscriptions)

    reports = reports.select do |r|
      (r.instances_timestamp.blank? || r.instances_timestamp < range_end) &&
        r.automated_report_subscriptions.present?
    end

    reports.group_by(&:interval)
  end

  def monthly
    reports_with_intervals['monthly']
  end

  def quarterly
    return unless [1, 4, 7, 10].include?(range_end.month)

    reports_with_intervals['quarterly']
  end

  def yearly
    return unless range_end.month == 1

    reports_with_intervals['yearly']
  end

  def range_end
    Time.zone.now.beginning_of_month
  end

  INTERVALS = { 'monthly' => 1, 'quarterly' => 3, 'yearly' => 12 }.freeze

  def send_email(report, identifier)
    subscriptions = report.automated_report_subscriptions
    report_class = report.report_class

    subscriptions.each do |subscription|
      Mail.deliver(to: subscription.subject.mail,
                   from: Rails.application.config
                              .reporting_service.mail[:from],
                   subject: 'AAF Reporting Service - New Report Generated',
                   body: email_message(identifier, report_class).render,
                   content_type: 'text/html; charset=UTF-8')
    end
  end

  def email_message(identifier, report_class)
    Lipstick::EmailMessage.new(title: 'AAF Reporting Service',
                               image_url: image_url('email_banner.png'),
                               content: email_body(identifier, report_class))
  end

  def email_body(identifier, report_class)
    url = automated_report_url(host: @base_url, identifier:)

    opts = { report_url: url, report_class: report_class.titleize }

    format(EMAIL_BODY, opts)
  end

  def image_url(image)
    (@base_url + ActionController::Base.helpers.image_path(image)).to_s
  end

  FILE = 'app/views/layouts/email_template.html.md'
  EMAIL_BODY = Rails.root.join(FILE).read.freeze

  private_constant :EMAIL_BODY, :FILE, :INTERVALS
end
