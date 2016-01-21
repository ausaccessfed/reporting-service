class ServiceProviderReportsController < ApplicationController
  before_action :permitted_service_providers
  before_action :service_provider
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

    @service_providers = active_sps.select do |sp|
      subject
      .permits?("objects:organization:#{sp.organization.identifier}:report")
    end
  end

  private

  def service_provider
    return unless params[:entity_id].present?

    @sp = @service_providers.detect do |sp|
      sp.entity_id == params[:entity_id]
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
    check_access!("objects:organization:#{@sp.organization.identifier}:report")
  end

  def range
    { start: Time.zone.parse(params[:start]),
      end: Time.zone.parse(params[:end]) }
  end
end
