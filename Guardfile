# frozen_string_literal: true

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  watch(helper.real_path('Gemfile'))
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^((bin|lib)/.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.+\.html\.slim)$}) { |m| "spec/#{m[1]}_spec.rb" }

  watch(%r{^app/controllers/(.+)_controller\.rb$}) do |m|
    [
      "spec/routing/#{m[1]}_routing_spec.rb",
      "spec/features/#{m[1]}_spec.rb"
    ]
  end

  watch('config/routes.rb') { 'spec/routing' }
  watch('app/controllers/application_controller.rb') { 'spec/controllers' }
  watch(%r{^app/views/layouts/.+$}) { %w[spec/views spec/features] }
  watch(%r{^app/assets/.+$}) { 'spec/features' }

  watch(%r{^spec/(spec|rails)_helper\.rb$}) { 'spec' }
  watch(%r{^spec/(support|factories)/.+\.rb$}) { 'spec' }
  watch(%r{^spec/.+/.+_spec\.rb$})
end

guard :rubocop, cli: '-R -D' do
  watch(/(Gemfile|Guardfile|Rakefile)$/)
  watch(/.+\.rb$/)
  watch(/.+\.rake$/)
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end

guard 'brakeman', run_on_start: true, quiet: true do
  watch(%r{^app/.+\.(slim|rb)$})
  watch(%r{^config/.+\.rb$})
  watch(%r{^lib/.+\.rb$})
  watch('Gemfile')
end

guard :unicorn, daemonize: true do
  watch('Gemfile.lock')
  watch(%r{^config/.+\.rb$})
end
