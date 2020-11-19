# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rspec'
require 'capybara/poltergeist'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  include FactoryBot::Syntax::Methods

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  Capybara.default_driver = Capybara.javascript_driver = :poltergeist

  def ide_config
    {
      host: 'ide.example.edu',
      cert: 'spec/api.crt',
      key: 'spec/api.key',
      admin_entitlements: ['urn:mace:aaf.edu.au:ide:internal:aaf-admin']
    }
  end

  config.before(:each) do
    allow(Authentication::SubjectReceiver.new).to receive(:ide_config)
      .and_return(ide_config)
  end

  config.around(:each, type: :feature) do |spec|
    WebMock.allow_net_connect!

    visit '/'
    spec.run
  ensure
    WebMock.disable_net_connect!
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
