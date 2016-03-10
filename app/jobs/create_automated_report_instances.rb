# frozen_string_literal: true
class CreateAutomatedReportInstances
  include Rails.application.routes.url_helpers

  def initialize
    @instances = []
    @base_url = Rails.application.config
                     .reporting_service
                     .url_options[:base_url]
  end

  def perform
    create_instances

    @instances.each do |instance|
      report = instance.automated_report

      send_email(report, instance.identifier)
    end
  end

  private

  def create_instances
    select_reports.each do |report|
      start = range_start(report.interval)

      next if instance_exists?(report, start)

      perform_create(report, start)
    end
  end

  def perform_create(report, start)
    identifier = SecureRandom.urlsafe_base64

    AutomatedReportInstance.transaction do
      instance = AutomatedReportInstance
                 .create!(identifier: identifier,
                          automated_report: report,
                          range_start: start)

      @instances += [instance]
    end
  end

  def instance_exists?(report, start)
    AutomatedReportInstance.find_by(range_start: start,
                                    automated_report: report)
  end

  def select_reports
    [monthly, quarterly, yearly].compact.reduce([], &:+)
  end

  def reports_with_intervals
    AutomatedReport
      .preload(:automated_report_subscriptions)
      .select { |r| !r.automated_report_subscriptions.blank? }
      .group_by(&:interval)
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

    opts = { report_url: url,
             report_class: report_class.titleize }

    format(EMAIL_BODY, opts)
  end

  def image_url(image)
    (@base_url + ActionController::Base.helpers.image_path(image)).to_s
  end

  FILE = 'app/views/layouts/email_template.html.md'.freeze
  EMAIL_BODY = File.read(Rails.root.join(FILE)).freeze

  private_constant :EMAIL_BODY, :FILE
end
