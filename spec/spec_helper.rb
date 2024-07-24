# frozen_string_literal: true

unless ARGV.include?('--dry-run')
  require 'simplecov'
  require 'simplecov-console'

  SimpleCov.formatter = SimpleCov::Formatter::Console
end

require 'support/capybara_setup'
require 'support/redis_helper'

RSpec.configure do |config|
  config.include RSpec::RedisHelper

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  # config.disable_monkey_patching!

  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.order = :random
  Kernel.srand config.seed
  RSpec::Matchers.define_negated_matcher :not_change, :change
end
