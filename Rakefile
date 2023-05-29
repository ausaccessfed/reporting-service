# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  require 'brakeman'
rescue LoadError
  :production
end

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

RuboCop::RakeTask.new if defined? RuboCop

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

task default: %i[rubocop spec brakeman]
