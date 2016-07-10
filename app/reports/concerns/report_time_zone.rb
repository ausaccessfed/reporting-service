# frozen_string_literal: true
module ReportTimeZone
  def create_time_instance_variables(start, finish)
    @start = convert_time_zone(start)
    @finish = convert_time_zone(finish)
  end

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
