# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rspec'
require 'selenium/webdriver'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  include FactoryBot::Syntax::Methods

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  Capybara.server = :puma, { Silent: true }

  if ENV.fetch('IS_DOCKER', false)
    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument('--headless')
    options.add_argument('--window-size=1400,1400')
    browser = :firefox
  else
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1400,1400')
    browser = :chrome
  end

  Capybara.register_driver :adapter do |app|
    Capybara::Selenium::Driver.new(app, browser: browser)
  end

  Capybara.register_driver :adapter_headless do |app|
    Capybara::Selenium::Driver.new(app, browser: browser, options: options)
  end
  Capybara.raise_server_errors = false
  Capybara.default_driver = Capybara.javascript_driver = if ENV.fetch('HEADLESS_TESTS',
                                                                      'true') == 'true'
                                                           :adapter_headless
                                                         else
                                                           :adapter
                                                         end

  def save_timestamped_screenshot(page, meta)
    filename = File.basename(meta[:file_path])
    line_number = meta[:line_number]

    time_now = Time.zone.now
    timestamp = "#{time_now.strftime('%Y-%m-%d-%H-%M-%S.')}#{(time_now.usec / 1000).to_i}"

    screenshot_name = "screenshot-#{filename}-#{line_number}-#{timestamp}.png"
    screenshot_path = "#{Rails.root.join('tmp', 'capybara')}/#{screenshot_name}"

    page.save_screenshot(screenshot_path)

    puts "\n  Screenshot: #{screenshot_path}"
  end

  config.after(:each, type: :feature) do |example|
    save_timestamped_screenshot(Capybara.page, example.metadata) if example.exception
  end

  def ide_config
    {
      admin_entitlements: ['urn:mace:aaf.edu.au:ide:internal:aaf-admin']
    }
  end

  config.before(:each) do
    allow(Authentication::SubjectReceiver.new).to receive(:ide_config)
      .and_return(ide_config)
  end
  config.include RSpec::Rails::RequestExampleGroup, type: :feature

  config.around(:each, type: :feature) do |spec|
    WebMock.allow_net_connect!

    visit '/'
    spec.run
  ensure
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
