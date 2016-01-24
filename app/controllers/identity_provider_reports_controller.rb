class IdentityProviderReportsController < SubscriberReportsController
  def sessions_report
    report_type = IdentityProviderSessionsReport
    @data = data_output(report_type, 10) unless params[:entity_id].blank?
  end

  def daily_demand_report
    report_type = IdentityProviderDailyDemandReport
    @data = data_output(report_type) unless params[:entity_id].blank?
  end

  def destination_services_report
    report_type = IdentityProviderDestinationServicesReport
    @data = data_output(report_type) unless params[:entity_id].blank?
  end

  private

  def model_object
    IdentityProvider
  end
end
