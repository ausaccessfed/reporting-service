class FederationReportsController < ApplicationController
  def federation_growth
    public_action

    @data = Rails.cache.fetch('public/federation-growth') do
      data = FederationGrowthReport.new(1.year.ago.utc, Time.now.utc).generate
      JSON.generate(data)
    end
  end
end
