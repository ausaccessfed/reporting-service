# frozen_string_literal: true

class AutomatedReportsController < AutomatedReports
  before_action :public_action, only: %i[index destroy]
  before_action :set_access_method, only: :subscribe

  def index
    @subscriptions = subscriptions.preload(:automated_report)
  end

  # rubocop:disable  Rails/I18nLocaleTexts
  def subscribe
    if subscription_exists?
      flash[:notice] = 'You have already subscribed to this report'
    else
      create_subscription
      flash[:notice] = 'You have successfully subscribed to this report'
    end
    # rubocop:enable  Rails/I18nLocaleTexts

    redirect_to(request.referer || dashboard_path)
  end

  def destroy
    object = subscriptions.find_by(identifier: params[:identifier])
    name = object.automated_report.target_name

    object.destroy
    flash[:target_name] = name

    redirect_to automated_reports_path
  end

  private

  def automated_report
    AutomatedReport.find_or_create_by!(automated_report_params)
  end

  def subscriptions
    @subject.automated_report_subscriptions
  end

  def create_subscription
    subscriptions.create!(identifier: SecureRandom.urlsafe_base64, automated_report:)
  end

  def subscription_exists?
    subscriptions.find_by(automated_report:)
  end

  def report_class
    params[:report_class]
  end

  def automated_report_params
    params.require(%i[report_class interval])
    params.require(:source) if AutomatedReport.report_class_needs_source?(params[:report_class])
    params.require(:target) if AutomatedReport.report_class_needs_target?(params[:report_class])
    params.permit(:interval, :target, :report_class, :source)
  end
end
