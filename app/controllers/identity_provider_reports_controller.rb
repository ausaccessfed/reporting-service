# frozen_string_literal: true
class IdentityProviderReportsController < SubscriberReports
  def sessions_report
    report_type = IdentityProviderSessionsReport
    @data = output(report_type, scaled_steps) unless params[:entity_id].blank?
  end

  def daily_demand_report
    report_type = IdentityProviderDailyDemandReport
    @data = output(report_type) unless params[:entity_id].blank?
  end

  def destination_services_report
    report_type = IdentityProviderDestinationServicesReport
    @data = output(report_type) unless params[:entity_id].blank?
  end

  private

  def model_object
    IdentityProvider
  end
end
