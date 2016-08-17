# frozen_string_literal: true
source 'https://rubygems.org'
gem 'rails', '~> 4.2.5'
gem 'mysql2'
gem 'sass-rails', require: false
gem 'uglifier', require: false
gem 'therubyracer', require: false
gem 'jbuilder'
gem 'slim'

gem 'redis'
gem 'redis-rails'

gem 'rapid-rack'
gem 'valhammer'
gem 'accession'
gem 'implicit-schema'

gem 'aws-sdk'
gem 'json-jwt'
gem 'torba-rails'

gem 'aaf-lipstick', git: 'https://github.com/ausaccessfed/aaf-lipstick',
                    branch: 'develop'

gem 'unicorn', require: false
gem 'god', require: false

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'fakeredis'
  gem 'webmock', require: false

  gem 'aaf-gumboot', git: 'https://github.com/ausaccessfed/aaf-gumboot',
                     branch: 'develop'

  gem 'pry', require: false
  gem 'byebug'

  gem 'capybara', require: false
  gem 'poltergeist', require: false
  gem 'launchy', require: false

  gem 'brakeman', '~> 3.2.1', require: false
  gem 'simplecov', require: false

  gem 'guard', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-brakeman', require: false
  gem 'guard-unicorn', require: false
  gem 'terminal-notifier-guard', require: false
  gem 'bullet'
end
