# frozen_string_literal: true

require 'rails_helper'
require 'gumboot/shared_examples/api_controller'

RSpec.describe API::APIController do
  include_examples 'API base controller'
end
