# frozen_string_literal: true
module ReportZone
  def convert_time_zone(time)
    time.in_time_zone(zone)
  end

  private

  def zone
    configuration.time_zone
  end

  def configuration
    Rails.application.config.reporting_service
  end
end
