require 'net/https'
require 'simple_google_auth/config'

module SimpleGoogleAuth
  mattr_accessor :config
  self.config = Config.new

  def self.configure
    yield config

    if config.refresh_stale_tokens
      config.request_parameters.merge!(access_type: "offline")
    end
  end
end

require 'simple_google_auth/http_client'
require 'simple_google_auth/oauth'
require 'simple_google_auth/authorization_uri_builder'
require 'simple_google_auth/engine'
require 'simple_google_auth/controller'
require 'simple_google_auth/receiver'

SimpleGoogleAuth.configure do |config|
  config.google_auth_url = "https://accounts.google.com/o/oauth2/auth"
  config.google_token_url = "https://accounts.google.com/o/oauth2/token"
  config.state_session_key_name = "simple-google-auth.state"
  config.data_session_key_name = "simple-google-auth.data"
  config.failed_login_path = "/"
  config.request_parameters = {scope: "openid email"}
  config.authenticate = lambda { raise "You must define an authenticate lambda that sets the session" }
end
