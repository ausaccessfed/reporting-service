# frozen_string_literal: true

class TabularReport
  prepend TabularReport::Lint

  class_attribute :options
  self.options = {}

  class <<self
    def inherited(klass)
      klass.options = klass.options.dup
    end

    def report_type(value)
      options[:type] = value
    end

    def header(*value)
      options[:header] = value
    end

    def footer(*value)
      options[:footer] = value
    end
  end

  def initialize(title)
    @title = title
  end

  def generate
    title = @title
    title += " (#{source_name})" if @source.present?

    self.class.options.merge(title: title, rows: rows)
  end
end
