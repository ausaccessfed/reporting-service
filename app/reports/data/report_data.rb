class Data
  module ReportData
    private

    def output_data(range, step_width, divider)
      report = average_rate sessions.pluck(:timestamp)

      range.step(step_width).each_with_object(sessions: []) do |t, data|
        average = report[t] ? (report[t].to_f / divider).round(1) : 0.0

        data[:sessions] << [t, average]
      end
    end
  end
end
