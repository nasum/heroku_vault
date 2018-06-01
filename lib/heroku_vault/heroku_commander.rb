require 'platform-api'

module HerokuVault
  class HerokuCommander
    def initialize
      @heroku = PlatformAPI.connect_oauth(ENV['HEROKU_TOKEN'])
    end

    def config_all(app_name)
      @heroku.config_var.info_for_app(app_name).to_json
    end

    def apply_config(app_name, body)
      @heroku.config_var.update(app_name, body)
    end
  end
end
