# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  require 'brakeman'
rescue LoadError
  :production
end

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

RuboCop::RakeTask.new if defined? RuboCop

task :brakeman do
  Brakeman.run app_path: '.', print_report: true, exit_on_warn: true
end

task default: %i[rubocop spec brakeman]
