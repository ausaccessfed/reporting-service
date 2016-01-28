class AdministratorReportsController < ApplicationController
  before_action { check_access! 'admin:reports' }

  def index
  end

  def subscriber_registrations_report
    return if params[:identifier].blank?

    @identifier = params[:identifier]
    report = SubscriberRegistrationsReport.new(@identifier)
    @data = JSON.generate(report.generate)
  end
end
