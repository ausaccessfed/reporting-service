# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }

  config.before do |spec|
    type = spec.metadata[:type]
    DatabaseCleaner.strategy = (type == :feature ? :truncation : :transaction)
  end

  config.before { DatabaseCleaner.start }

  config.after { DatabaseCleaner.clean }
end
