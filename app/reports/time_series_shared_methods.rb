module TimeSeriesSharedMethods
  private

  def output_data(range, report, step_width, divider)
    range.step(step_width).each_with_object(sessions: []) do |t, data|
      average = report[t] ? (report[t].to_f / divider).round(1) : 0.0

      data[:sessions] << [t, average]
    end
  end

  def per_hour_output(default_sessions = sessions)
    report = sessions_count(default_sessions) do |session|
      offset = session - @start
      offset - (offset % @steps.hour.to_i)
    end

    output_data range, report, @steps.hours, @steps
  end

  def daily_demand_output(default_sessions = sessions)
    report = sessions_count(default_sessions) do |session|
      offset = (session - session.beginning_of_day).to_i
      offset - (offset % 1.minute)
    end

    output_data 0..86_340, report, 1.minute, days_count
  end

  def range
    (0..(@finish - @start).to_i)
  end

  def sessions_count(sessions)
    sessions.pluck(:timestamp).each_with_object({}) do |session, data|
      point = yield session
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end

  def days_count
    (@start.to_i..@finish.to_i).step(1.day).count
  end

  def sessions(where_args = {})
    DiscoveryServiceEvent
      .within_range(@start, @finish).where(where_args).sessions
  end

  def idp_sessions
    sessions identity_provider: @identity_provider
  end

  def sp_sessions
    sessions service_provider: @service_provider
  end
end
