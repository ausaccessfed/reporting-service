# frozen_string_literal: true
# Base class for all time series reports.
class TimeSeriesReport
  prepend TimeSeriesReport::Lint

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

    def units(value)
      options[:units] = value
    end
  end

  def initialize(title, range = nil)
    @title = title
    @range = range
  end

  def generate
    range = @range.try(:transform_values, &:xmlschema)

    self.class.options.merge(title: @title, data: data, range: range).compact
  end
end
