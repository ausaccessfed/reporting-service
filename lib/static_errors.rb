# frozen_string_literal: true

require 'lipstick/errors/static_errors'

class StaticErrors
  def self.write_public_error_files
    Lipstick::StaticErrors.write_public_error_files
  end
end
