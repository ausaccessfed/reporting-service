# Base class for all time series reports.
class TimeSeriesReport
  class_attribute :options
  self.options = {}

  class <<self
    def inherited(klass)
      klass.options = klass.options.dup
    end

    def report_type(value)
      options[:type] = value
    end

    def y_label(value)
      labels(y: value)
    end

    def series(opts)
      options[:series] = opts.keys
      labels(opts)
    end

    def labels(opts)
      options[:labels] = (options[:labels].try(:slice, :y) || {}).merge(opts)
    end
  end

  def initialize(title, start, finish)
    @title = title
    @range = { start: start, end: finish }
  end

  def generate
    self.class.options.merge(title: @title, range: @range, data: data)
  end
end
