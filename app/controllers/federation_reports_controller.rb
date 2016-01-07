class FederationReportsController < ApplicationController
  def federation_growth
    public_action

    @data = Rails.cache.fetch('public/federation-growth') do
      report = FederationGrowthReport.new(1.year.ago.utc, Time.now.utc)
      JSON.generate(report.generate)
    end
  end

  def federated_sessions
    public_action

    @data = Rails.cache.fetch('public/federated-sessions') do
      report = FederatedSessionsReport.new(1.year.ago.utc, Time.now.utc, 10)
      JSON.generate(report.generate)
    end
  end
end
