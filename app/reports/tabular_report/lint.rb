# frozen_string_literal: true
class TabularReport
  module Lint
    include GenericLint

    def generate
      super.tap { |output| validate_tabular_output(output) }
    end

    private

    def validate_tabular_output(output)
      validate_rows(output)
      validate_header(output)
      validate_footer(output)

      validate_shape(output)
    end

    def validate_header(output)
      validate_required_field(output, :header, Array)
      validate_tabular_row_data(output, :header)
    end

    def validate_footer(output)
      validate_required_field(output, :footer, Array, allow_blank: true)
      validate_tabular_row_data(output, :footer)
    end

    def validate_rows(output)
      validate_required_field(output, :rows, Array, allow_blank: true)
      validate_tabular_row_data(output, :rows, 'row data')
    end

    def validate_shape(output)
      width = output[:header].first.length

      ensure_width(output, :rows, width, 'row data has inconsistent width')
      ensure_width(output, :header, width, 'header size is incorrect')
      ensure_width(output, :footer, width, 'footer size is incorrect')
    end

    def validate_tabular_row_data(output, key, name = key)
      output[key].each do |row|
        fail_with("#{name} must be an array of arrays") unless row.is_a?(Array)

        row.each do |field|
          fail_with("#{name} fields must be strings") unless field.is_a?(String)
        end
      end
    end

    def ensure_width(output, key, width, error)
      output[key].each do |row|
        fail_with(error) unless row.length == width
      end
    end

    def fail_with(message)
      raise("Invalid tabular data: #{message}")
    end
  end
end
