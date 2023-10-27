# frozen_string_literal: true

class AdministratorReportsController < ApplicationController
  include Steps

  before_action { check_access! 'admin:report' }
  before_action :set_range_params, except: %i[subscriber_registrations_report index]
  before_action :set_source, except: %i[subscriber_registrations_report federation_growth_report index]

  def index
  end

  def subscriber_registrations_report
    return if params[:identifier].blank?

    @identifier = params[:identifier]
    report = SubscriberRegistrationsReport.new(@identifier)
    @data = JSON.generate(report.generate)
  end

  def federation_growth_report
    return if params[:start].blank? || params[:end].blank?

    report = FederationGrowthReport.new(start, finish)
    @data = JSON.generate(report.generate)
  end

  def daily_demand_report
    return if params[:start].blank? || params[:end].blank?

    report = DailyDemandReport.new(start, finish, @source)
    @data = JSON.generate(report.generate)
  end

  def federated_sessions_report
    return if params[:start].blank? || params[:end].blank?

    report = FederatedSessionsReport.new(start, finish, scaled_steps, @source)
    @data = JSON.generate(report.generate)
  end

  def identity_provider_utilization_report
    return if params[:start].blank? || params[:end].blank?

    report = IdentityProviderUtilizationReport.new(start, finish, @source)
    @data = JSON.generate(report.generate)
  end

  def service_provider_utilization_report
    return if params[:start].blank? || params[:end].blank?

    report = ServiceProviderUtilizationReport.new(start, finish, @source)
    @data = JSON.generate(report.generate)
  end

  private

  def set_source
    return nil if params[:source].blank?

    @source = params[:source]
  end
end
