class AdministratorReportsController < ApplicationController
  before_action { check_access! 'admin:reports' }
  before_action :range, except: [:subscriber_registrations_report]

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

  def range
    @start = params[:start] ? convert_time(params[:start], true) : nil
    @end = params[:end] ? convert_time(params[:end]) : nil
  end

  def convert_time(time, flag = nil)
    return Time.zone.parse(time).beginning_of_day if flag
    Time.zone.parse(time).end_of_day
  end

  def scaled_steps
    width = (@end - @start) / 365_000
    return 10 if width > 10
    return 1 if width < 1
    width.to_i
  end
end
