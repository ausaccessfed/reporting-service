class IdentityProviderReportsController < ApplicationController
  before_action :permitted_identity_providers
  before_action :identity_provider
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

    @identity_providers = active_idps.select do |idp|
      subject
      .permits?("objects:organization:#{idp.organization.identifier}:report")
    end
  end

  private

  def identity_provider
    return unless params[:entity_id].present?

    @idp = @identity_providers.detect do |idp|
      idp.entity_id == params[:entity_id]
    end
  end

  def data_output(report_type, step = nil)
    report = generate_report(report_type, step)
    JSON.generate(report.generate)
  end

  def generate_report(report_type, step = nil)
    if step
      report_type.new(params[:entity_id], range[:start], range[:end], step)
    else
      report_type.new(params[:entity_id], range[:start], range[:end])
    end
  end

  def access_method
    return public_action unless params[:entity_id].present?
    check_access!("objects:organization:#{@idp.organization.identifier}:report")
  end

  def range
    { start: Time.zone.parse(params[:start]),
      end: Time.zone.parse(params[:end]) }
  end
end
