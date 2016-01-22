class IdentityProviderReportsController < SubscriberReportsController
  before_action :permitted_identity_providers
  before_action :requested_entity
  before_action :access_method

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

  def permitted_identity_providers
    active_idps = IdentityProvider.preload(:organization).active

    @entities = active_idps.select do |idp|
      subject.permits? permission_string(idp)
    end
  end
end
