class AutomatedReportsController < ApplicationController
  before_action :set_subscriptions
  before_action { public_action }

  def index
  end

  def unsubscribe
    subscription = @subscriptions.detect do |s|
      s.identifier == params[:report_id]
    end

    notice = 'successfully unsubscribed' if subscription.destroy

    respond_to do |format|
      format.html { redirect_to automated_reports_path }
    end
  end

  private

  def set_subscriptions
    @subscriptions = AutomatedReportSubscription
                     .where(subject_id: @subject.id)
                     .preload(:automated_report)
  end
end
