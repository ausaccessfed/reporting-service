class RandomTimeSeriesReport < TimeSeriesReport
  report_type 'random-time-series'

  y_label 'randomly generated number'

  series total: 'Total Response Time',
         database: 'Database Time',
         render: 'Render Time'

  def initialize(host, start, finish)
    super("A randomly generated graph for #{host}", start, finish)
    @start = start
    @finish = finish
  end

  def data
    rng = Distribution::Normal.rng
    range = (0..(@finish.to_i - @start.to_i)).step(1800)

    range.each_with_object(total: [], database: [], render: []) do |n, map|
      r1 = rng.call.abs * 5
      r2 = rng.call * 3
      r2 = -2.0 if r2 < -2.0
      r3 = rng.call.abs * 5

      map[:database] << [n, 30 + r2]
      map[:render] << [n, 10 + r1]
      map[:total] << [n, 40 + r1 + r2 + r3]
    end
  end
end
