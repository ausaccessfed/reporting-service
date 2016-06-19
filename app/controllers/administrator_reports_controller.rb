# frozen_string_literal: true
class AdministratorReportsController < ApplicationController
  before_action { check_access! 'admin:report' }
  before_action :set_range_params,
                except: [:subscriber_registrations_report, :index]

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

    report = DailyDemandReport.new(start, finish)
    @data = JSON.generate(report.generate)
  end

  def federated_sessions_report
    return if params[:start].blank? || params[:end].blank?

    report = FederatedSessionsReport.new(start, finish, scaled_steps)
    @data = JSON.generate(report.generate)
  end

  def identity_provider_utilization_report
    return if params[:start].blank? || params[:end].blank?

    report = IdentityProviderUtilizationReport.new(start, finish)
    @data = JSON.generate(report.generate)
  end

  def service_provider_utilization_report
    return if params[:start].blank? || params[:end].blank?

    report = ServiceProviderUtilizationReport.new(start, finish)
    @data = JSON.generate(report.generate)
  end

  private

  def set_range_params
    @start = params[:start]
    @end = params[:end]
  end

  def start
    return nil if params[:start].blank?
    Time.zone.parse(params[:start]).beginning_of_day
  end

  def finish
    return nil if params[:end].blank?
    Time.zone.parse(params[:end]).tomorrow.beginning_of_day
  end

  def scaled_steps
    range = finish - start

    return 24 if range >= 1.year
    return 12 if range >= 6.months
    return 6 if range >= 3.months
    return 2 if range >= 1.month
    1
  end
end
