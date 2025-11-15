require "json"
require "jwt"
require_relative "../models/user"
require_relative "../services/jwt_service"

class AuthController
  def signup(req)
    data = JSON.parse(req.body.read)

    username = data["username"]
    password = data["password"]

    if User.first(username: username)
      LOG.info "User #{username} already exists"
      return [409, {}, [{ error: "username already exists" }.to_json]]
    end

    user = User.create(username: username, password: password)
    token = JwtService.encode({ sub: user["id"] })

    LOG.info "User #{user['username']} created with ID #{user['id']}"
    [201, { "Content-Type" => "application/json" },
      [{ token: token, user: { id: user["id"], username: user["username"] } }.to_json]]
  end

  def login(req)
    data = JSON.parse(req.body.read)

    username = data["username"]
    password = data["password"]

    user = User.first(username: username)

    if user && user.authenticate(password)
      puts(user[:id])
      token = JwtService.encode({ sub: user[:id] })
      LOG.info "User #{username} logged in"
      return [200, { "Content-Type" => "application/json" }, [{ token: token }.to_json]]
    else
      LOG.info "User #{username} failed to log in"
      return [401, {}, [{ error: "invalid credentials" }.to_json]]
    end
  end

  private

  def parse_json(req)
    JSON.parse(req.body.read)
  rescue
    {}
  end

  def json(status, obj)
    [status, { "Content-Type" => "application/json" }, [obj.to_json]]
  end
end
