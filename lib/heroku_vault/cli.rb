require 'thor'
require 'json'

module HerokuVault
  class Cli < Thor
    desc "encrypt config_file", "encrypt usage"
    method_option :password, aliases: :p, required: true
    def encrypt(file_name)
      config_data = open(file_name) do |io|
        JSON.load(io)
      end

      encryptor = HerokuVault::EncrypterFactory.create(options[:password])

      encrypted = config_data.map do |key, val|
        [key, encryptor.encrypt_and_sign(val)]
      end

      puts encrypted.to_h.to_json
    end

    desc "decrypt config_file", "decrypt usage"
    method_option :password, aliases: :p, required: true
    def decrypt(file_name)
      config_data = open(file_name) do |io|
        JSON.load(io)
      end

      encryptor = HerokuVault::EncrypterFactory.create(options[:password])

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

    desc "create_encrypted_config heroku_app_name", "create encrypted heroku config"
    method_option :password, aliases: :p, required: true
    method_option :output, aliases: :o
    def create_encrypted_config(app_name)
      heroku = HerokuVault::HerokuCommander.new
      config_data = heroku.config_all(app_name)

      encryptor = HerokuVault::EncrypterFactory.create(options[:password])

      encrypted = JSON.parse(config_data).map do |key, val|
        [key, encryptor.encrypt_and_sign(val)]
      end

      file_name = options[:output]
      file_name ||= 'encrypted.json'

      File.open(file_name, 'w') do |file|
        JSON.dump(encrypted, file)
      end
    end

    desc "push heroku_app_name", "push usage"
    def push
    end
  end
end
