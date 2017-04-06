# frozen_string_literal: true

require 'lipstick/errors/static_errors'
require 'fileutils'

FileUtils.mkdir_p Rails.root.join('public')
Lipstick::StaticErrors.write_public_error_files
