# frozen_string_literal: true

module ApplicationHelper
  include Lipstick::Helpers::LayoutHelper
  include Lipstick::Helpers::NavHelper
  include Lipstick::Helpers::FormHelper

  VERSION = '1.4.0'

  # rubocop:disable Rails/HelperInstanceVariable
  def permitted?(action)
    @subject.try(:permits?, action)
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def environment_string
    Rails.application.config.reporting_service.environment_string
  end
end
