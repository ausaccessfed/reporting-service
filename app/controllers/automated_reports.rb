# frozen_string_literal: true

class AutomatedReports < ApplicationController
  private

  def entity
    automated_report.target_object
  end

  SUBSCRIBER_REPORTS = %w[
    IdentityProviderSessionsReport
    IdentityProviderDailyDemandReport
    IdentityProviderDestinationServicesReport
    ServiceProviderSessionsReport
    ServiceProviderDailyDemandReport
    ServiceProviderSourceIdentityProvidersReport
  ].freeze

  PUBLIC_REPORTS = %w[
    DailyDemandReport
    FederatedSessionsReport
    FederationGrowthReport
    IdentityProviderAttributesReport
    ProvidedAttributeReport
    RequestedAttributeReport
    ServiceCompatibilityReport
  ].freeze

  def public_report?
    PUBLIC_REPORTS.include?(report_class)
  end

  def subscriber_report?
    SUBSCRIBER_REPORTS.include?(report_class)
  end

  def subscriber_permissions
    "objects:organization:#{entity.organization.identifier}:report"
  end

  def set_access_method
    return public_action if public_report?
    return check_access!(subscriber_permissions) if subscriber_report?

    check_access! 'admin:report'
  end

  private_constant :SUBSCRIBER_REPORTS, :PUBLIC_REPORTS
end
