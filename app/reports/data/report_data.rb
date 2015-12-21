class Data
  module ReportData
    private

    def output_data(range, report, step_width, divider)
      range.step(step_width).each_with_object(sessions: []) do |t, data|
        average = report[t] ? (report[t].to_f / divider).round(1) : 0.0

        data[:sessions] << [t, average]
      end
    end

    def average_rate(sessions, offset, divider)
      sessions.each_with_object({}) do |session, data|
        t = session - offset
        point = t - (t % divider)
        (data[point.to_i] ||= 0) << data[point.to_i] += 1
      end
    end

    def sessions
      DiscoveryServiceEvent.within_range(@start, @finish)
        .sessions.pluck(:timestamp)
    end
  end
end
