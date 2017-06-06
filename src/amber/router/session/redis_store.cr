require "redis"

module Amber::Router::Session
  class RedisStore < AbstractStore
    getter store : Redis
    property expires : Int32
    property key : String
    property session_id : String
    property cookies : Amber::Router::Cookies::Store
    property id : String

    def initialize(@store, @cookies, @key, @expires = 120)
      @id = current_session
      @session_id = "#{@key}:#{@id}"
    end

    def destroy
      @store.del(session_id)
    end

    def [](key)
      @store.hget(session_id, key)
    end

    def []?(key)
      key?(key)
    end

    def []=(key, value)
      @store.hset(session_id, key, value)
    end

    def key?(key)
      @store.hexists(session_id, key) == 1 ? true : false
    end

    def keys
      @store.hkeys(session_id)
    end

    def values
      @store.hvals(session_id)
    end

    def to_h
      @store.hmget(session_id).each_slice(2).to_h
    end

    def update(hash : Hash(String, String))
      @store.hmset(session_id, hash)
    end

    def delete(key)
      @store.hdel(session_id, key) if key?(key)
    end

    def fetch(key, default = nil)
      return self[key] if key?(key)
      (self[key] = default)
      default
    end

    def empty?
      # 1 since the session id key always gets set technically is never empty
      @store.hlen(session_id) <= 1
    end

    def set_session
      cookies.encrypted.set(key, session_id, expires: (Time.now + expires.seconds), http_only: true)

      store.pipelined do |pipeline|
        pipeline.hset(session_id, key, id)
        pipeline.expire(session_id, expires)
      end
    end

    def current_session
      @cookies.encrypted[@key] || SecureRandom.uuid
    end
  end
end
