class AuthRoute
  def initialize(auth_controller)
    @auth_controller = auth_controller
  end

  def call(env)
    req = Rack::Request.new(env)
    method = req.request_method
    path = req.path_info

    LOG.info "AuthRoute received: #{method} #{path}"

    case true
    when method == 'POST' && path == '/signup'
      validate_json_body(req) { @auth_controller.signup(req) }
    when method == 'POST' && path == '/login'
      validate_json_body(req) { @auth_controller.login(req) }
    else
      nil
    end
  rescue JSON::ParserError
    LOG.error "Invalid JSON body in request: #{method} #{path}"
    [400, { "Content-Type" => "application/json" }, [{ error: "Invalid JSON" }.to_json]]
  end

  private

  def validate_json_body(req)
    JSON.parse(req.body.read) # Verifica que el cuerpo sea JSON válido
    req.body.rewind # Reposiciona el stream para que el controlador pueda leerlo
    yield
  end
end
