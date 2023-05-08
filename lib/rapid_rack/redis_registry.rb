module RapidRack
  module RedisRegistry
    def register_jti(jti)
      key = "rapid_rack:jti:#{jti}"
      redis.setnx(key, 1) && redis.expire(key, 60)
    end

    def redis
      Redis.new
    end
  end
end
