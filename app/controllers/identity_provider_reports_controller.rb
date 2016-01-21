class IdentityProviderReportsController < ApplicationController
  before_action :permitted_identity_providers
  before_action :identity_provider
  before_action :access_method

  def sessions_report
    report_type = IdentityProviderSessionsReport

    @data = data_output('public/identity-provider-sessions',
                        report_type, 10) unless params[:entity_id].blank?
  end

  def daily_demand_report
    report_type = IdentityProviderDailyDemandReport

    @data = data_output('public/identity-provider-daily-demand',
                        report_type) unless params[:entity_id].blank?
  end

  def destination_services_report
    report_type = IdentityProviderDestinationServicesReport

    @data = data_output('public/identity-provider-destination-services',
                        report_type) unless params[:entity_id].blank?
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

  def data_output(template, report_type, step = nil)
    Rails.cache.fetch(template) do
      report = generate_report(report_type, step)
      JSON.generate(report.generate)
    end
  end

  def generate_report(report_type, step = nil)
    return report_type
      .new(params[:entity_id], range[:start], range[:end]) unless step

    report_type.new(params[:entity_id], range[:start], range[:end], step)
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
