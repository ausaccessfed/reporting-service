# frozen_string_literal: true
module GenericLint
  def generate
    super.tap { |output| validate_report_output(output) }
  end

  def validate_report_output(output)
    fail_with('output is blank') if output.blank?

    validate_required_field(output, :type, String)
    validate_required_field(output, :title, String)
  end

  def validate_required_field(output, field, type, allow_blank: false)
    f = output[field]

    fail_with("#{field} is nil") unless f
    fail_with("incorrect type for #{field}") unless f.is_a?(type)
    fail_with("#{field} is blank") if f.blank? && !allow_blank
  end
end
