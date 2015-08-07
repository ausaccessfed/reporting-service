ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }

  config.around(:each) do |spec|
    type = spec.metadata[:type]
    DatabaseCleaner.strategy = (type == :feature ? :truncation : :transaction)

    DatabaseCleaner.with_cleaning { spec.run }
  end

  config.infer_spec_type_from_file_location!
end
