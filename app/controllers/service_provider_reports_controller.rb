class ServiceProviderReportsController < SubscriberReportsController
  def sessions_report
    report_type = ServiceProviderSessionsReport
    @data = data_output(report_type, 1) unless params[:entity_id].blank?
  end

  def daily_demand_report
    report_type = ServiceProviderDailyDemandReport
    @data = data_output(report_type) unless params[:entity_id].blank?
  end

  def source_identity_providers_report
    report_type = ServiceProviderSourceIdentityProvidersReport
    @data = data_output(report_type) unless params[:entity_id].blank?
  end

  private

  def model_object
    ServiceProvider
  end
end
