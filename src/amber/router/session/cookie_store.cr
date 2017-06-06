module Amber::Router::Session
  # This is the default Cookie Store
  class CookieStore < AbstractStore
    property secret : String
    property key : String
    property expires : Int32
    property store : Amber::Router::Cookies::Store
    property session : Hash(String, String)

    def initialize(@store, @key, @expires, @secret)
      @session = current_session
      @session[key] = SecureRandom.uuid
    end

    def id
      @session[key]
    end

    def destroy
      @session.clear
    end

    def [](key)
      @session[key]
    end

    def []?(key)
      @session.has_key?(key)
    end

    def []=(key, value)
      @session[key] = value.to_s
    end

    def key?(key)
      @session.has_key?(key)
    end

    def keys
      @session.keys
    end

    def values
      @session.values
    end

    def to_h
      @session
    end

    def update(hash : Hash(String, String))
      hash.each do |key, value|
        @session[key] = value
      end
      @session
    end

    def delete(key)
      @session.delete(key) if key?(key)
    end

    def fetch(key, default = nil)
      @session.fetch(key, default)
    end

    def empty?
      @session.select { |_key, _| _key != key }.empty?
    end

    def set_session
      store.encrypted.set(key, session.to_json, expires: (Time.now + expires.seconds), http_only: true)
    end

    def current_session
      Hash(String, String).from_json(@store.encrypted[key] || "{}")
    rescue e : JSON::ParseException
      Hash(String, String).new
    end
  end
end
