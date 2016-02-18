class AutomatedReportsController < ApplicationController
  before_action :set_subscriptions
  before_action { public_action }

  def index
  end

  def destroy
    subscription = @subscriptions
                   .find_by(identifier: params[:identifier])

    subscription.destroy if subscription

    redirect_to automated_reports_path
  end

  private

  def set_subscriptions
    @subscriptions = AutomatedReportSubscription
                     .where(subject_id: @subject.id)
                     .preload(:automated_report)
  end
end
