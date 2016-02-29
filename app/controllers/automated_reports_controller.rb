class AutomatedReportsController < AutomatedReports
  before_action :public_action, only: [:index, :destroy]
  before_action :set_access_method, only: :subscribe

  def index
    @subscriptions = subject_subscriptions
  end

  def subscribe
    redirect_to :back
  end

  def destroy
    target_name = subscription.automated_report.target_name
    flash[:target_name] = target_name if subscription.destroy

    redirect_to automated_reports_path
  end

  private

  def subject_subscriptions
    AutomatedReportSubscription
      .where(subject: @subject)
      .preload(:automated_report)
  end

  def subscription
    subject_subscriptions
      .find_by(identifier: params[:identifier])
  end

  def automated_report_params
    params.require(:automated_report)
      .permit(:interval, :target, :report_class)
  end
end
