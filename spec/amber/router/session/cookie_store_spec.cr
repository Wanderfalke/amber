require "../../../../spec_helper"

module Amber::Router::Session
  COOKIE_STORE = Amber::Router::Cookies::Store.new(Amber::Server.key_generator)
  EXPIRES = 120 # 2 minutes

  describe CookieStore do
    describe "#id" do
      it "returns a UUID" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store.id.not_nil!.size.should eq 36
      end
    end

    describe "#destroy" do
      it "clears session" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store["name"] = "David"
        cookie_store.destroy

        cookie_store.empty?.should be_true
      end
    end

    describe "#[]" do
      it "gets key, value" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store["name"] = "David"
        cookie_store["name"].should eq "David"
      end
    end

    describe "#[]?" do
      it "returns true when key exists" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store["name"] = "David"

        cookie_store["name"]?.should eq true
      end

      it "returns false when key does not exists" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store["name"]?.should eq false
      end
    end

    describe "#[]=" do
      it "sets a key value" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store["name"] = "David"

        cookie_store["name"].should eq "David"
      end

      it "updates key value" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store["name"] = "David"
        cookie_store["name"] = "Frank"

        cookie_store["name"].should eq "Frank"
      end
    end

    describe "#key?" do
      context "key exists" do
        it "returns true" do
          cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

          cookie_store["name"] = "David"

          cookie_store.key?("name").should eq true
        end
      end

      context "key does not exists" do
        it "returns false" do
          cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

          cookie_store.key?("name").should eq false
        end
      end
    end

    describe "#keys" do
      it "returns a list of available keys" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store["a"] = "a"
        cookie_store["b"] = "c"
        cookie_store["c"] = "c"

        cookie_store.keys.should eq %w(ses a b c)
      end
    end

    describe "#values" do
      it "returns a list of available keys" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store["a"] = "a"
        cookie_store["b"] = "b"
        cookie_store["c"] = "c"

        cookie_store.delete("ses")

        cookie_store.values.should eq %w(a b c)
      end
    end

    describe "#update" do
      it "updates all keys by hash" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")
        cookie_store["a"] = "a"
        cookie_store["b"] = "b"
        cookie_store["c"] = "c"

        cookie_store.update({"a" => "1", "b" => "2", "c" => "3"})
        cookie_store.delete("ses")

        cookie_store.values.should eq %w(1 2 3)
      end
    end

    describe "#fetch" do
      context "when key is not set" do
        it "fetches default value" do
          cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

          cookie_store.fetch("name", "Jordan").should eq "Jordan"
        end
      end

      context "when key is set" do
        it "it fetches previously set value" do
          cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

          cookie_store["name"] = "Michael"

          cookie_store.fetch("name", "Jordan").should eq "Michael"
        end
      end
    end

    describe "#empty?" do
      it "returns true when session is empty" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store.empty?.should eq true
      end

      it "returns false when session is not empty" do
        cookie_store = CookieStore.new(COOKIE_STORE, "ses", EXPIRES, "secret")

        cookie_store["user_id"] = "1"

        cookie_store.empty?.should eq false
      end
    end
  end
end
