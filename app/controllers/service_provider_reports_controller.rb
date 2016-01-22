class ServiceProviderReportsController < ApplicationController
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
