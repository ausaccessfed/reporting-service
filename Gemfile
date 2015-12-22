source 'https://rubygems.org'

gem 'rails', '4.2.3'
gem 'mysql2'
gem 'sass-rails', '~> 5.0'
gem 'uglifier'
gem 'jbuilder'
gem 'slim'

gem 'redis'
gem 'redis-rails'

gem 'rapid-rack'
gem 'valhammer'
gem 'accession'

gem 'aaf-lipstick', git: 'https://github.com/ausaccessfed/aaf-lipstick',
                    branch: 'private/lipstick-2.0-pre'

gem 'unicorn', require: false
gem 'god', require: false

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap', '~> 3.3'
  gem 'rails-assets-jquery', '~> 1.11'
  gem 'rails-assets-jquery-validate'
  gem 'rails-assets-pickadate', '3.5.6'
  gem 'rails-assets-d3', '~> 3.5'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'fakeredis'
  gem 'webmock', require: false

  gem 'distribution' # TODO: Remove this when not needed anymore.

  gem 'aaf-gumboot', git: 'https://github.com/ausaccessfed/aaf-gumboot',
                     branch: 'develop'

  gem 'pry', require: false
  gem 'byebug'
  gem 'web-console'

  gem 'capybara', require: false
  gem 'poltergeist', require: false
  gem 'launchy', require: false

  gem 'brakeman', require: false
  gem 'simplecov', require: false

  gem 'guard', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-brakeman', require: false
  gem 'guard-unicorn', require: false
  gem 'terminal-notifier-guard', require: false
end
