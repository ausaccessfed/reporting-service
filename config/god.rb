# frozen_string_literal: true
require 'yaml'
require 'fileutils'

$0 = "god-#{God::VERSION}: #{__FILE__}"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
RAILS_ENV = ENV['RAILS_ENV'] || 'production'

PID_FILE_DIRECTORY = God.pid_file_directory = File.join(ROOT, 'tmp', 'pids')
LOG_DIRECTORY = File.join(ROOT, 'tmp', 'logs')

FileUtils.mkdir_p(PID_FILE_DIRECTORY)
FileUtils.mkdir_p(LOG_DIRECTORY)

def defaults(w, name)
  w.name = name

  w.stop_signal = 'QUIT'

  w.keepalive
  w.dir = ROOT

  w.log = File.join(LOG_DIRECTORY, "#{name}.log")
end

God.watch do |w|
  defaults(w, 'unicorn')

  config = YAML.load_file(File.join(ROOT, 'config', 'deploy.yml'))
  port = config['unicorn_port']

  w.start = "bundle exec unicorn -c config/unicorn.rb -D -p #{port}"
  w.restart = -> { God.registry['unicorn'].signal('USR2') }

  w.env = { 'RAILS_ENV' => RAILS_ENV }
  w.pid_file = File.join(PID_FILE_DIRECTORY, 'unicorn.pid')
end
