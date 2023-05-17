# frozen_string_literal: true

## TODO: remove unicorn and gem references once migrated

ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

worker_processes 5
timeout 300
preload_app true
pid File.join(ROOT, 'tmp', 'pids', 'unicorn.pid')
stdout_path '/tmp/log/stdout.log'
stderr_path '/tmp/log/stderr.log'
# stdout_path ENV.fetch('STDOUT', '/var/log/aaf/reporting/puma/stdout.log')
# stderr_path ENV.fetch('STDERR', '/var/log/aaf/reporting/puma/stderr.log')
# listen ENV.fetch('PORT', 8080)
before_fork do |server, _worker|
  old_pid = File.join(ROOT, 'tmp', 'pids', 'unicorn.pid.oldbin')
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      :not_running
    end
  end
end

class Unicorn::HttpServer # rubocop:disable Style/ClassAndModuleChildren
  def proc_name(tag)
    $0 = [File.basename(START_CTX[0]), 'reporting',
          tag].concat(START_CTX[:argv]).join(' ')
  end
end
