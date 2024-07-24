# frozen_string_literal: true
#
module RSpec
  module RedisHelper
    # When this module is included into the rspec config,
    # it will set up an around(:each) block to clear redis.
    def self.included(rspec)
      rspec.around(:each) { |example| with_clean_redis { example.run } }
    end

    def redis(&)
      @redis ||= ::Rails.application.config.redis_client
    end

    def with_clean_redis(&)
      redis.flushall # clean before run
      begin
        yield
      ensure
        redis.flushall # clean up after run
      end
    end
  end
end
