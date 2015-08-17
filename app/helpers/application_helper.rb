module ApplicationHelper
  include Lipstick::Helpers::LayoutHelper
  include Lipstick::Helpers::NavHelper
  include Lipstick::Helpers::FormHelper

  VERSION = '0.0.1'

  def permitted?(*)
    true # TODO
  end

  def environment_string
    'TODO' # TODO
  end
end
