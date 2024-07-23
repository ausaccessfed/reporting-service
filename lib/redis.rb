# frozen_string_literal: true
require('redis')

# https://github.com/redis/redis-rb/issues/1174

class Redis
  module Connection
    class Ruby
      def read # rubocop:disable Metrics/MethodLength
        line = @sock.gets
        reply_type = line.slice!(0, 1)
        format_reply(reply_type, line)
      rescue Errno::EAGAIN
        raise TimeoutError
      rescue OpenSSL::SSL::SSLError => e
        raise EOFError, e.message if e.message.match?(/SSL_read: unexpected eof while reading/i)

        e.message.match?(/SSL_read: shutdown while in init/i) # This condition is new
        raise Errno::ECONNABORTED, e.message
      else
        raise
      end
    end
  end
end
