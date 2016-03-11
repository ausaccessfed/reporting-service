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
    instances = []

    AutomatedReportInstance.transaction do
      select_reports.each do |report|
        start = range_start(report.interval)

        next if instance_exists?(instances, start, report)

        instances += [perform_create(report, start)]
      end
    end

    instances
  end

  def perform_create(report, start)
    AutomatedReportInstance
      .create!(identifier: SecureRandom.urlsafe_base64,
               automated_report: report, range_start: start)
  end

  def instance_exists?(instances, start, report)
    instances.detect do |i|
      (i.range_start == start) && (i.automated_report == report)
    end
  end

  def select_reports
    [monthly, quarterly, yearly].compact.reduce([], &:+)
  end

  def reports_with_intervals
    AutomatedReport
      .preload(:automated_report_instances)
      .preload(:automated_report_subscriptions)
      .select { |r| !r.automated_report_subscriptions.blank? }
      .group_by(&:interval)
  end

  def filter_reports(reports, interval)
    reports.select do |report|
      !report.automated_report_instances
             .detect { |ins| ins.range_start == range_start(interval) }
    end
  end

  def monthly
    reports = reports_with_intervals['monthly']
    filter_reports(reports, 'monthly')
  end

  def quarterly
    return unless [1, 4, 7, 10].include?(time.month)

    reports = reports_with_intervals['quarterly']
    filter_reports(reports, 'quarterly')
  end

  def yearly
    return unless time.month == 1

    reports = reports_with_intervals['yearly']
    filter_reports(reports, 'yearly')
  end

  def time
    Time.zone.now
  end

  INTERVALS = { 'monthly' => 1, 'quarterly' => 3, 'yearly' => 12 }.freeze

  def range_start(interval)
    start_time = time - INTERVALS[interval].months
    start_time.beginning_of_month
  end

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
    path = automated_reports_url host: @base_url
    url = path + '/' + identifier

    opts = { report_url: url, report_class: report_class.titleize }

    format(EMAIL_BODY, opts)
  end

  def image_url(image)
    (@base_url + ActionController::Base.helpers.image_path(image)).to_s
  end

  FILE = 'app/views/layouts/email_template.html.md'.freeze
  EMAIL_BODY = File.read(Rails.root.join(FILE)).freeze

  private_constant :EMAIL_BODY, :FILE, :INTERVALS
end
