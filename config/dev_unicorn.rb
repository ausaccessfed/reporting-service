# frozen_string_literal: true
listen 8080
preload_app false
stdout_path '/dev/null'

root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
pid File.join(root, 'tmp', 'pids', 'unicorn.pid')

class DevWorker
  class <<self
    attr_accessor :attempts
  end
  @attempts = []
end

before_fork do |_, _|
  DevWorker.attempts << Time.now.to_i
  attempts = DevWorker.attempts.last(3)

  if attempts.length > 2 && (attempts.last - attempts.first) < 10
    $stderr.print('Sleeping before next restart...')
    sleep(10)
    $stderr.puts
  end
end

logger_obj = Logger.new($stderr)
logger_obj.level = Logger::WARN
logger logger_obj
