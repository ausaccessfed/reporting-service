class AdministratorReportsController < ApplicationController
  before_action { check_access! 'admin:reports' }
  before_action :populate_range,
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

    report = FederationGrowthReport.new(@start, @end)
    @data = JSON.generate(report.generate)
  end

  def daily_demand_report
    return if params[:start].blank? || params[:end].blank?

    report = DailyDemandReport.new(@start, @end)
    @data = JSON.generate(report.generate)
  end

  def federated_sessions_report
    return if params[:start].blank? || params[:end].blank?

    report = FederatedSessionsReport.new(@start, @end, scaled_steps)
    @data = JSON.generate(report.generate)
  end

  private

  def populate_range
    @start = parsed_start_time
    @end = parsed_end_time
  end

  def parsed_start_time
    return nil if params[:start].blank?
    Time.zone.parse(params[:start]).beginning_of_day
  end

  def parsed_end_time
    return nil if params[:end].blank?
    Time.zone.parse(params[:end]).end_of_day
  end

  def scaled_steps
    width = (@end - @start) / 365_000
    return 12 if width > 12
    return 1 if width < 1
    width.to_i
  end
end
