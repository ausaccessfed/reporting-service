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

  private

  def range
    @start = params[:start] ? Time.zone.parse(params[:start]) : nil
    @end = params[:end] ? Time.zone.parse(params[:end]) : nil
  end
end
