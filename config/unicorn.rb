# frozen_string_literal: true

ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

worker_processes 5
timeout 300
preload_app true
port ENV.fetch('PORT', 8082)
pid File.join(ROOT, 'tmp', 'pids', 'unicorn.pid')
bind "tcp://127.0.0.1:#{ENV.fetch('PORT', 8082)}"
stdout_path ENV.fetch('STDOUT', '/var/log/aaf/reporting/puma/stdout.log')
stderr_path ENV.fetch('STDERR', '/var/log/aaf/reporting/puma/stderr.log')

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
