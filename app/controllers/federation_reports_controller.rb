# frozen_string_literal: true

class FederationReportsController < ApplicationController
  before_action :set_range
  before_action :set_source, only: %i[federated_sessions_report
                                      daily_demand_report]

  def federation_growth_report
    public_action

    @data = Rails.cache.fetch('public/federation-growth') do
      report = FederationGrowthReport.new(@start, @end)
      JSON.generate(report.generate)
    end
  end

  def federated_sessions_report
    public_action

    @data = Rails.cache.fetch('public/federated-sessions') do
      report = FederatedSessionsReport.new(@start, @end, 10, @source)
      JSON.generate(report.generate)
    end
  end

  def daily_demand_report
    public_action

    @data = Rails.cache.fetch('public/daily-demand') do
      report = DailyDemandReport.new(@start, @end, @source)
      JSON.generate(report.generate)
    end
  end

  private

  def set_range
    @start = 1.year.ago.beginning_of_day
    @end = Time.zone.tomorrow.beginning_of_day
  end

  def set_source
    @source = params[:source]
    return @source if @source.present?

    # Have to provide a default for public reports
    # (DailyDemand and FederatedSessionsReport)
    # which do not have a form to set the source
    @source = Rails.application.config.reporting_service.default_session_source
    # Complete fall back: default to DS if source is not set in params
    # and not in app_config.
    @source = 'DS' if @source.blank?
  end
end
