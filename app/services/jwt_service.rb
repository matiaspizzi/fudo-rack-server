require "jwt"

class JwtService
  SECRET = ENV.fetch("JWT_SECRET") { "secret_dev_key" }
  ALGORITHM = "HS256"
  EXP = 3600

  def self.encode(payload)
    payload = payload.dup
    payload["exp"] = Time.now.to_i + EXP
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, SECRET, true, algorithm: ALGORITHM)
  end
end