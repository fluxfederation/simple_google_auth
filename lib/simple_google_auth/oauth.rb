module SimpleGoogleAuth
  class OAuth
    def initialize(config)
      @config = config
      @client = HttpClient.new(@config.google_token_url)
    end

    def exchange_code_for_auth_token!(code)
      response = @client.request(
        code: code,
        grant_type: "authorization_code",
        client_id: @config.client_id,
        client_secret: @config.client_secret,
        redirect_uri: @config.redirect_uri)

      parse_auth_response(response)
    end

    def refresh_auth_token!(refresh_token)
      return if refresh_token.blank?

      response = @client.request(
        refresh_token: refresh_token,
        client_id: @config.client_id,
        client_secret: @config.client_secret,
        grant_type: "refresh_token")

      parse_auth_response(response).merge("refresh_token" => refresh_token)
    end

    private
    def parse_auth_response(response)
      auth_data = JSON.parse(response)

      auth_data["expires_at"] = calculate_expiry(auth_data).to_s

      id_data = decode_id_data(auth_data.delete("id_token"))
      auth_data.merge!(id_data)
    end

    def calculate_expiry(auth_data)
      Time.now + auth_data["expires_in"] - 5.seconds
    end

    def decode_id_data(id_data)
      id_data_64 = id_data.split(".")[1]
      id_data_64 << "=" until id_data_64.length % 4 == 0
      JSON.parse(Base64.decode64(id_data_64))
    end
  end
end