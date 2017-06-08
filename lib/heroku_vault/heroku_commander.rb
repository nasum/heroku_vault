require 'platform-api'

module HerokuVault
  class HerokuCommander
    def initialize
      @heroku = PlatformAPI.connect_oauth(ENV['HEROKU_TOKEN'])
    end

    def config_all(app_name)
      @heroku.config_var.info_for_app(app_name).to_json
    end
  end
end
