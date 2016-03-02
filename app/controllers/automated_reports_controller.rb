class AutomatedReportsController < AutomatedReports
  before_action :public_action, only: [:index, :destroy]
  before_action :set_access_method, only: :subscribe

  def index
    @subscriptions = subscriptions
  end

  def subscribe
    if subscription_exists?
      flash[:notice] = 'You have already subscribed to this report'
    else
      create_subscription
      flash[:notice] = 'You have successfully subscribed to this report'
    end

    redirect_to params[:request_path]
  end

  def destroy
    object = subscriptions.find_by(identifier: params[:identifier])
    name = object.automated_report.target_name

    flash[:target_name] = name if object.destroy

    redirect_to automated_reports_path
  end

  private

  def automated_report
    AutomatedReport.find_or_create_by!(automated_report_params)
  end

  def subscriptions
    @subject.automated_report_subscriptions.preload(:automated_report)
  end

  def create_subscription
    subscriptions.create!(identifier: SecureRandom.urlsafe_base64,
                          automated_report: automated_report)
  end

  def subscription_exists?
    subscriptions.find_by(automated_report: automated_report)
  end

  def report_class
    params[:report_class]
  end

  def automated_report_params
    params.permit(:interval, :target, :report_class)
  end
end
