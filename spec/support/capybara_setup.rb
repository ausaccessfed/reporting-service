# frozen_string_literal: true

require 'capybara'
require 'capybara/rspec'
require 'capybara/cuprite'
require 'webmock/rspec'

Capybara.default_max_wait_time = 5

# Normalizes whitespaces when using `has_text?` and similar matchers
Capybara.default_normalize_ws = true

# Where to store artifacts (e.g. screenshots, downloaded files, etc.)
Capybara.save_path = 'tmp/capybara'

Capybara.server = :puma, { Silent: true }

browser_options = { 'ignore-certificate-errors' => true }
browser_options['no-sandbox'] = true

# We call this :cooprite to avoid a naming collision with the preexisting :cuprite driver.
# See https://bytemeta.vip/index.php/repo/rubycdp/cuprite/issues/180 for info.
Capybara.register_driver(:cooprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1280, 800],
    browser_options:,
    process_timeout: 10,
    timeout: 10,
    inspector: true,
    headless: ENV.fetch('HEADLESS_TESTS', 'true') == 'true'
  )
end

Capybara.default_driver = Capybara.javascript_driver = :cooprite

def save_error(page, meta)
  filename = File.basename(meta[:file_path])
  line_number = meta[:line_number]

  time_now = Time.zone.now
  timestamp = "#{time_now.strftime('%Y-%m-%d-%H-%M-%S.')}#{(time_now.usec / 1000).to_i}"

  name = "screenshot-#{filename}-#{line_number}-#{timestamp}"

  page.save_screenshot("#{name}.png")
  puts "\n  Screenshot: #{name}.png"

  page.save_page("#{name}.html")
  puts "\n  Html: #{name}.html"
end

RSpec.configure do |config|
  config.after(:each, type: :feature) do |example|
    if example.exception && ENV.fetch('SAVE_TEST_FAILURES', 'false') == 'true'
      save_error(Capybara.page, example.metadata)
    end
  end

  config.around(:each, type: :feature) do |spec|
    WebMock.allow_net_connect!

    spec.run
  ensure
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
