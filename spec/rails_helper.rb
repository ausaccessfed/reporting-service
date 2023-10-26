# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  include FactoryBot::Syntax::Methods

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  def ide_config
    { admin_entitlements: ['urn:mace:aaf.edu.au:ide:internal:aaf-admin'] }
  end

  config.before { allow(Authentication::SubjectReceiver.new).to receive(:ide_config).and_return(ide_config) }
  config.include RSpec::Rails::RequestExampleGroup, type: :feature
  config.include Capybara::RSpecMatchers, type: :feature
  config.include Capybara::RSpecMatchers, type: :request
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
