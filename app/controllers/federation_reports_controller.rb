class FederationReportsController < ApplicationController
  def federation_growth
    public_action

    @data = Rails.cache.fetch('public/federation-growth') do
      data = FederationGrowthReport.new(1.year.ago.utc, Time.now.utc)
      JSON.generate(data.generate)
    end
  end

  def federated_sessions
    public_action

    @data = Rails.cache.fetch('public/federated-sessions') do
      data = FederatedSessionsReport.new(1.year.ago.utc, Time.now.utc, 10)
      JSON.generate(data.generate)
    end
  end
end
