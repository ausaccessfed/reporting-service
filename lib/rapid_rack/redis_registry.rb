# frozen_string_literal: true

module RapidRack
  module RedisRegistry
    def register_jti(jti)
      key = "rapid_rack:jti:#{jti}"
      redis.setnx(key, 1) && redis.expire(key, 60)
    end

    def redis
      Rails.application.config.redis_client
    end
  end
end
