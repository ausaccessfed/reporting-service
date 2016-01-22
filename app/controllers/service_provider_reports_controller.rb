class ServiceProviderReportsController < SubscriberReportsController
  before_action :permitted_service_providers
  before_action :entities
  before_action :access_method

  def sessions_report
    report_type = ServiceProviderSessionsReport
    @data = data_output(report_type, 10) unless params[:entity_id].blank?
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

  def permitted_service_providers
    active_sps = ServiceProvider.preload(:organization).active

    @entities = active_sps.select do |sp|
      subject.permits? permission_string(sp)
    end
  end
end
