class AutomatedReportsController < AutomatedReports
  before_action :set_subscriptions
  before_action :public_action, only: [:index, :destroy]
  before_action :set_access_method, only: :subscribe

  def index
  end

  def subscribe
    message = 'You have already subscribed to this report'
    success_message = 'You have successfully subscribed to this report'

    if !detect_subscription.blank?
      flash[:notice] = message
    elsif subscribe_to_report
      flash[:notice] = success_message
    end

    redirect_to :back
  end

  def destroy
    subscription = @subscriptions
                   .find_by(identifier: params[:identifier])

    destroy_subscription subscription
    redirect_to automated_reports_path
  end

  private

  def detect_subscription
    @subscriptions.detect do |s|
      s.automated_report.interval == interval &&
        s.automated_report.report_class == report_class &&
        s.automated_report.target == target
    end
  end

  def subscribe_to_report
    return unless detect_subscription.blank?

    AutomatedReportSubscription
      .create(subject: subject,
              automated_report_id: automated_report.id,
              identifier: SecureRandom.urlsafe_base64)
  end

  def automated_report
    report = AutomatedReport.find_by(interval: interval,
                                     target: target,
                                     report_class: report_class)

    return report unless report.blank?

    AutomatedReport.create(interval: interval,
                           target: target,
                           report_class: report_class)
  end

  def set_subscriptions
    @subscriptions = AutomatedReportSubscription
                     .where(subject_id: @subject.id)
                     .preload(:automated_report)
  end

  def destroy_subscription(subscription)
    return unless subscription

    message = subscription.automated_report.target_name
    flash[:target_name] = message if subscription.destroy
  end

  def interval
    params[:interval]
  end

  def target
    params[:target]
  end

  def report_class
    params[:report_class]
  end

  SUBSCRIBER_REPORTS = {
    'IdentityProviderSessionsReport' => IdentityProvider,
    'IdentityProviderDailyDemandReport' => IdentityProvider,
    'IdentityProviderDestinationServicesReport' => IdentityProvider,
    'ServiceProviderSessionsReport' => ServiceProvider,
    'ServiceProviderDailyDemandReport' => ServiceProvider,
    'ServiceProviderSourceIdentityProvidersReport' => ServiceProvider
  }.freeze

  def entity
    SUBSCRIBER_REPORTS[report_class]
      .find_by_identifying_attribute(target)
  end

  private_constant :SUBSCRIBER_REPORTS
end
