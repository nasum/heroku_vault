require 'thor'
require 'json'

module HerokuVault
  class Cli < Thor
    desc "encrypt config_file", "encrypt usage"
    method_option :output, aliases: :o, required: true
    method_option :salt, aliases: :s
    def encrypt(file_name)
      password = enter_password
      salt = enter_salt
      encryptor = HerokuVault::EncrypterFactory.create(password, salt)

      config_data = open(file_name) do |io|
        JSON.load(io)
      end

      encrypted = config_data.map do |key, val|
        [key, encryptor.encrypt_and_sign(val)]
      end

      output_file(options[:output], JSON.parse(encrypted.to_h.to_json))
    end

    desc "decrypt config_file", "decrypt usage"
    def decrypt(file_name)
      config_data = open(file_name) do |io|
        JSON.load(io)
      end

      password = enter_password
      salt = enter_salt
      encryptor = HerokuVault::EncrypterFactory.create(password, salt)

      decrypted = config_data.map do |key, val|
        [key, encryptor.decrypt_and_verify(val)]
      end

      puts decrypted.to_h.to_json
    end

    desc "fetch heroku_app_name", "fetch usage"
    method_option :output, aliases: :o, required: true
    def fetch(app_name)
      heroku = HerokuVault::HerokuCommander.new
      config_data = heroku.config_all(app_name)
      file_name = options[:output]
      output_file(file_name, JSON.parse(config_data))
    end

    desc "create_encrypted_config heroku_app_name", "create encrypted heroku config"
    method_option :output, aliases: :o, required: true
    def create_encrypted_config(app_name)
      password = enter_password
      salt = enter_salt
      heroku = HerokuVault::HerokuCommander.new
      config_data = heroku.config_all(app_name)
      encryptor = HerokuVault::EncrypterFactory.create(password, salt)

      encrypted = JSON.parse(config_data).map do |key, val|
        [key, encryptor.encrypt_and_sign(val)]
      end

      file_name = options[:output]
      output_file(file_name, JSON.parse(encrypted.to_h.to_json))
    end

    desc "apply heroku_app_name", "apply config"
    method_option :file, aliases: :f, required: true
    def apply(app_name)
      password = enter_password
      salt = enter_salt
      encryptor = HerokuVault::EncrypterFactory.create(password, salt)
      heroku = HerokuVault::HerokuCommander.new

      File.open(options[:file]) do |file|
        config_data = file.read
        decrypted_config = JSON.parse(config_data).map do |key, val|
          [key, encryptor.decrypt_and_verify(val)]
        end

        decrypted_config.each do |key, val|
          obj = {}
          obj[key] = val
          heroku.apply_config(app_name, obj)
        end
      end
    end

    private

    def enter_password
      print 'enter paswword: '
      password = STDIN.noecho(&:gets)
      puts
      return password
    end

    def enter_salt
      print 'enter salt: '
      salt = STDIN.noecho(&:gets)
      puts
      salt
    end

    def output_file(file_name, json_hash)
      File.open(file_name, 'w') do |file|
        JSON.pretty_generate(json_hash).each_line do |line|
          file.puts line
        end
      end
    end
  end
end
