require 'thor'
require 'json'
require 'active_support'

module HerokuVault
  class Cli < Thor
    desc "encrypt config_file", "encrypt usage"
    option :password, aliases: :p, required: true
    def encrypt(file_name)
      config_data = open(file_name) do |io|
        JSON.load(io)
      end

      key = ActiveSupport::KeyGenerator.new(options[:password]).generate_key('salt', 32)
      encryptor = ActiveSupport::MessageEncryptor.new(key, cipher: "aes-256-cbc")

      encrypted = config_data.map do |key, val|
        [key, encryptor.encrypt_and_sign(val)]
      end

      puts encrypted.to_h.to_json
    end

    desc "decrypt config_file", "decrypt usage"
    option :password, aliases: :p, required: true
    def decrypt(file_name)
      config_data = open(file_name) do |io|
        JSON.load(io)
      end

      key = ActiveSupport::KeyGenerator.new(options[:password]).generate_key('salt', 32)
      encryptor = ActiveSupport::MessageEncryptor.new(key, cipher: "aes-256-cbc")

      decrypted = config_data.map do |key, val|
        [key, encryptor.decrypt_and_verify(val)]
      end

      puts decrypted.to_h.to_json
    end

    desc "fetch heroku_app_name", "fetch usage"
    def fetch(app_name)
      heroku = HerokuVault::HerokuCommander.new
      puts heroku.config_all(app_name)
    end

    desc "push heroku_app_name", "push usage"
    def push
    end
  end
end
