class ApiAuthenticationFailure
  LOGIN_PATH = "/api/v1/auth/login"

  def self.call(env)
    body = response_body(env).to_json

    [
      401,
      {
        "Content-Type" => "application/json; charset=utf-8",
        "Cache-Control" => "no-store",
        "Content-Length" => body.bytesize.to_s
      },
      [ body ]
    ]
  end

  def self.response_body(env)
    attempted_path = env.dig("warden.options", :attempted_path)

    if attempted_path&.start_with?(LOGIN_PATH)
      { error: { code: "invalid_credentials", message: "Email or password is invalid" } }
    else
      { error: { code: "authentication_required", message: "Authentication is required" } }
    end
  end

  private_class_method :response_body
end
