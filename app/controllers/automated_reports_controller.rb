class AutomatedReportsController < ApplicationController
  before_action :set_subscriptions
  before_action { public_action }

  def index
  end

  def destroy
    subscription = @subscriptions
                   .find_by(identifier: params[:identifier])

    destroy_subscription subscription
    redirect_to automated_reports_path
  end

  private

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
end
