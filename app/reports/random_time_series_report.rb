class RandomTimeSeriesReport < TimeSeriesReport
  report_type 'random-time-series'
  y_label 'randomly generated number'
  units ' ms'

  series total: 'Total Response Time',
         database: 'Database Time',
         render: 'Render Time'

  def initialize(host, start, finish)
    super("A randomly generated graph for #{host}", start, finish)
    @start = start
    @finish = finish
  end

  def data
    range.each_with_object(total: [], database: [], render: []) do |n, map|
      d, r, t = points(n)
      map[:database] << d
      map[:render] << r
      map[:total] << t
    end
  end

  private

  def rng
    @rng ||= Distribution::Normal.rng
  end

  def range
    (0..(@finish.to_i - @start.to_i)).step(1800)
  end

  def randoms
    r1 = rng.call.abs * 5
    r2 = rng.call * 3
    r2 = -2.0 if r2 < -2.0
    r3 = rng.call.abs * 5
    [r1, r2, r3]
  end

  def points(n)
    r1, r2, r3 = randoms

    d = 30 + r2
    r = 10 + r1
    t = r3

    [[n, d], [n, r], [n, d + r + t]]
  end

  class Line < RandomTimeSeriesReport
    report_type 'random-time-series-line'
  end

  class Stacked < RandomTimeSeriesReport
    series total: 'Total Response Time',
           render: 'Render Time',
           database: 'Database Time'

    def points(n)
      r1, r2, r3 = randoms

      d = 30 + r2
      r = 10 + r1
      t = r3

      [[n, d, d], [n, d + r, r], [n, d + r + t, d + r + t]]
    end
  end
end
