# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  require 'brakeman'
rescue LoadError
  :production
end

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

RuboCop::RakeTask.new if defined?(RuboCop)

task brakeman: :environment do
  result = Brakeman.run app_path: '.', print_report: true, pager: false

  unless result.filtered_warnings.empty?
    puts "Brakeman found #{result.filtered_warnings.count} warnings"
    exit 1
  end
end

task write_public_errors: :environment do
  StaticErrors.write_public_error_files
end

Rake::Task['assets:precompile'].enhance { Rake::Task['write_public_errors'].invoke }

task lint_js: :environment do
  puts 'Running javascript linting... '
  sh 'yarn run lint', verbose: false
end

task lint_js_fix: :environment do
  puts 'Running javascript linting... '
  sh 'yarn run lint --fix', verbose: false
end

task lint_rb: :environment do
  puts 'Running syntax tree on ruby... '
  sh "stree check '**/*.rb' '**/*.rake' Gemfile Rakefile", verbose: false
end

task lint_rb_fix: :environment do
  puts 'Running syntax tree on ruby... '
  sh "stree write '**/*.rb' '**/*.rake' Gemfile Rakefile", verbose: false
end

task lint_md: :environment do
  puts 'Running prettier on markdown... '
  sh "./node_modules/.bin/pprettier --check '**/*.md'", verbose: false
end

task lint_md_fix: :environment do
  puts 'Running prettier on markdown... '
  sh "./node_modules/.bin/pprettier --write '**/*.md'", verbose: false
end

task rubocop: :environment do
  puts 'Running Rubocop... '
  sh 'rubocop --no-parallel', verbose: false
end

task rubocop_fix: :environment do
  puts 'Running Rubocop... '
  sh 'rubocop -A', verbose: false
end

task default: %i[brakeman lint_rb rubocop lint_md lint_js parallel:spec]
task lint: %i[lint_rb_fix lint_md_fix rubocop_fix lint_js_fix]
