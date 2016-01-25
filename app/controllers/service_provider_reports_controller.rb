class ServiceProviderReportsController < SubscriberReportsController
  def sessions_report
    report_type = ServiceProviderSessionsReport
    @data = output(report_type, scaled_steps) unless params[:entity_id].blank?
  end

  def daily_demand_report
    report_type = ServiceProviderDailyDemandReport
    @data = output(report_type) unless params[:entity_id].blank?
  end

  def source_identity_providers_report
    report_type = ServiceProviderSourceIdentityProvidersReport
    @data = output(report_type) unless params[:entity_id].blank?
  end

  private

  def model_object
    ServiceProvider
  end
end
