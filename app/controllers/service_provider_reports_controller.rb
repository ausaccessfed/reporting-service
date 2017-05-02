# frozen_string_literal: true

class ServiceProviderReportsController < SubscriberReports
  def sessions_report
    report_type = ServiceProviderSessionsReport
    @data = output(report_type, scaled_steps) if params[:entity_id].present?
  end

  def daily_demand_report
    report_type = ServiceProviderDailyDemandReport
    @data = output(report_type) if params[:entity_id].present?
  end

  def source_identity_providers_report
    report_type = ServiceProviderSourceIdentityProvidersReport
    @data = output(report_type) if params[:entity_id].present?
  end

  private

  def model_object
    ServiceProvider
  end
end
