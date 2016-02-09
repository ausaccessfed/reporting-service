class AutomatedReportsController < ApplicationController
  before_action :set_subscriptions, only: :index

  def index
    public_action
  end

  private

  def set_subscriptions
    @subscriptions = AutomatedReportSubscription
                     .where(subject_id: @subject.id)
                     .preload(:automated_report)
  end
end
