# frozen_string_literal: true
module ReportTimeZone
  def create_time_instance_variables(objects = {})
    objects.each do |key, val|
      value = convert_time_zone(val)
      instance_variable_set("@#{key}", value)
    end
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
