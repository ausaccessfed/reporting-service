module ReportsSharedMethods
  private

  def output_data(range, report, step_width, divider, decimal_places = 1)
    range.step(step_width).each_with_object(sessions: []) do |t, data|
      average = average report, t, divider, decimal_places

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
      offset - (offset % 5.minutes)
    end

    output_data 0..86_340, report, 5.minutes, days_count, 2
  end

  def utilization_report(target)
    sessions.preload(target)
            .group_by(&target)
            .map { |obj, val| [obj.name, val.count.to_s] }
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

  def average(report, time, divider, decimal_places = 1)
    report[time] ? (report[time].to_f / divider).round(decimal_places) : 0.0
  end

  def sessions(where_args = {})
    DiscoveryServiceEvent
      .within_range(@start, @finish).where(where_args).sessions
  end

  def idp_sessions
    sessions selected_idp: @identity_provider.entity_id
  end

  def sp_sessions(sp = nil)
    sp ||= @service_provider
    sessions initiating_sp: sp.entity_id
  end
end
