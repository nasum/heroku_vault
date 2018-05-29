require 'active_support'

module HerokuVault
  module EncrypterFactory
    def self.create(password)
      key = ActiveSupport::KeyGenerator.new(password).generate_key('salt', 32)
      return ActiveSupport::MessageEncryptor.new(key, cipher: "aes-256-cbc")
    end
  end
end
