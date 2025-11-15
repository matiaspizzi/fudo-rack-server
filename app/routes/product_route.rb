class ProductRoute
  def initialize(controller)
    @controller = controller
  end

  def call(env)
    req = Rack::Request.new(env)
    method = req.request_method
    path = req.path_info

    LOG.info "ProductRoute received: #{method} #{path}"

    case true
    when method == "GET" && path == '/product'
      @controller.index(req)
    when method == "GET" && path.match?(%r{^/product/\d+$})
      validate_id_in_path(path) { @controller.show(req) }
    when method == "POST" && path == '/product'
      @controller.create(req)
    else
      LOG.warn "Route not found: #{method} #{path}"
      nil
    end
  end

  private

  def validate_id_in_path(path)
    id = path.split("/").last
    if id.match?(/^\d+$/)
      yield
    else
      LOG.error "Invalid product ID in path: #{path}"
      [400, { "Content-Type" => "application/json" }, [{ error: "Invalid product ID" }.to_json]]
    end
  end
end