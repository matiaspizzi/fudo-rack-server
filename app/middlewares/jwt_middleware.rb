require_relative "../models/user"
require_relative "../services/jwt_service"

class JwtMiddleware

  PUBLIC_PATHS = [
    %r{^/openapi.yml$},
    %r{^/AUTHORS$},
    %r{^/signup$},
    %r{^/login$}
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path

    if PUBLIC_PATHS.any? { |r| path.match?(r) }
      return @app.call(env)
    end

    auth_header = env["HTTP_AUTHORIZATION"]

    if auth_header.nil? || !auth_header.start_with?("Bearer ")
      return unauthorized("missing_authorization")
    end

    token = auth_header.split(" ").last

    begin
      payload, _ = JwtService.decode(token)
      puts(payload)
      user = User.first(id: payload["sub"])

      if user.nil?
        return unauthorized("invalid_token_user")
      end
      env["current_user"] = user
      env["jwt_payload"] = payload
    rescue JWT::ExpiredSignature
      return unauthorized("token_expired")
    rescue JWT::DecodeError => e
      return unauthorized("invalid_token")
    end

    @app.call(env)
  end

  private

  def unauthorized(reason)
    body = { error: "unauthorized", reason: reason }.to_json
    [401, { "Content-Type" => "application/json", "Cache-Control" => "no-store" }, [body]]
  end
end
