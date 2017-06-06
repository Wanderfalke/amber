module Amber::Router::Session
  # All Session Stores should implement the following API
  abstract class AbstractStore
    abstract def id
    abstract def destroy
    abstract def [](key)
    abstract def []?(key)
    abstract def []=(key, value)
    abstract def key?(key)
    abstract def keys
    abstract def values
    abstract def to_h
    abstract def update(other_hash)
    abstract def delete(key)
    abstract def fetch(key, default = nil)
    abstract def empty?
  end
end
