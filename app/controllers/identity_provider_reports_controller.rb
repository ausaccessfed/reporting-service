class IdentityProviderReportsController < ApplicationController
  before_action :permitted_identity_providers
  before_action :identity_provider
  before_action :access_method

  def sessions_report
    @data = data_output('public/identity-provider-sessions') unless
      params[:entity_id].blank?
  end

  private

  def permitted_identity_providers
    active_idps = IdentityProvider.preload(:organization).active

    @identity_providers = active_idps.select do |idp|
      subject
      .permits?("objects:organization:#{idp.organization.identifier}:report")
    end
  end

  def identity_provider
    return unless params[:entity_id].present?

    @idp = @identity_providers.detect do |idp|
      idp.entity_id == params[:entity_id]
    end
  end

  def data_output(template)
    Rails.cache.fetch(template) do
      report = IdentityProviderSessionsReport
               .new(params[:entity_id], range[:start], range[:end], 10)
      JSON.generate(report.generate)
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
