module TimeSeriesSharedMethods
  private

  def output_data(range, report, step_width, divider)
    range.step(step_width).each_with_object(sessions: []) do |t, data|
      average = report[t] ? (report[t].to_f / divider).round(1) : 0.0

      data[:sessions] << [t, average]
    end
  end

  def range
    (0..(@finish - @start).to_i)
  end

  def average_rate(sessions, offset, divider)
    sessions.pluck(:timestamp).each_with_object({}) do |session, data|
      t = session - offset
      point = t - (t % divider)
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end

  def daily_demand_average_rate(sessions)
    sessions.pluck(:timestamp).each_with_object({}) do |session, data|
      offset = (session - session.beginning_of_day).to_i
      point = offset - (offset % 1.minute)
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
end
