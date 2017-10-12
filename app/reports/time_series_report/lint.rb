# frozen_string_literal: true

class TimeSeriesReport
  module Lint
    include GenericLint

    def generate
      super.tap { |output| validate_time_series_output(output) }
    end

    private

    def validate_time_series_output(output)
      validate_required_field(output, :units, String, allow_blank: true)

      validate_series(output)
      validate_labels(output)
      validate_range(output)
      validate_data(output)
    end

    def validate_series(output)
      validate_required_field(output, :series, Array)

      return if output[:series].all? { |k| k.to_sym != :y }
      fail_with('series name "y" is not permitted')
    end

    def validate_labels(output)
      validate_required_field(output, :labels, Hash)

      labels = output[:labels]
      fail_with('missing label for y axis') unless labels.key?(:y)

      ensure_series_entries(output, labels.except(:y), 'label') do |k, v|
        fail_with("label for #{k} is not a String") unless v.is_a?(String)
      end
    end

    def validate_range(output)
      return unless output[:range]

      validate_required_field(output, :range, Hash)

      %i[start end].each do |k|
        v = output[:range][k]
        fail_with("time range is missing #{k}") unless v

        next if v.is_a?(String) && Time.zone.parse(v)
        fail_with("#{k} of time range is invalid")
      end
    end

    def validate_data(output)
      validate_required_field(output, :data, Hash)

      ensure_series_entries(output, output[:data], 'data') do |k, v|
        fail_with("data for #{k} is not an Array") unless v.is_a?(Array)
        fail_with("data for #{k} is blank") if v.empty?

        validate_data_range(output, k, v)
      end
    end

    def validate_data_range(output, series, data)
      return unless output[:range]

      start, finish = time_range(output)

      prev = -1

      data.each do |(s, v)|
        fail_with("data for #{series} is unsorted") if prev > s
        prev = s

        fail_with("data for #{series} is not numeric") unless v.is_a?(Numeric)

        next if s >= 0 && s.seconds.since(start) <= finish
        fail_with("data for #{series} is outside time range")
      end
    end

    def fail_with(message)
      raise("Invalid time series data: #{message}")
    end

    def time_range(output)
      output[:range].values_at(:start, :end).map { |s| Time.zone.parse(s) }
    end

    def ensure_series_entries(output, hash, kind)
      items = hash.dup

      output[:series].each do |k|
        v = items.delete(k.to_sym)
        next yield(k, v) if v

        fail_with("missing #{kind} for #{k}")
      end

      items.each_key { |k| fail_with("extra #{kind} present for #{k}") }
    end
  end
end
