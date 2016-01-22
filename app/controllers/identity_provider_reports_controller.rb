class IdentityProviderReportsController < ApplicationController
  before_action :permitted_identity_providers
  before_action :entities
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

  def entities
    return unless params[:entity_id].present?

    @entity = @entities.detect do |entity|
      entity.entity_id == params[:entity_id]
    end
  end

  def data_output(report_type, step = nil)
    report = generate_report(report_type, step)
    JSON.generate(report.generate)
  end

  def generate_report(report_type, step = nil)
    @start = Time.zone.parse(params[:start])
    @end = Time.zone.parse(params[:end])
    @entity_id = params[:entity_id]

    return report_type.new(@entity_id, @start, @end, step) if step
    report_type.new(@entity_id, @start, @end)
  end

  def access_method
    return public_action unless params[:entity_id].present?
    check_access! permission_string(@entity)
  end

  def permission_string(entity)
    "objects:organization:#{entity.organization.identifier}:report"
  end
end
