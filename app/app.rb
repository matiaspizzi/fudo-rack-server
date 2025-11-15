# frozen_string_literal: true

require_relative './db/sequel'
require_relative 'controllers/auth_controller'
require_relative 'controllers/product_controller'
require_relative 'routes/auth_route'
require_relative 'routes/product_route'
require_relative 'middlewares/jwt_middleware'
require_relative 'middlewares/gzip_middleware'
require_relative 'logger'

class App
  STATIC_FILES = {
    openapi: "openapi.yml",
    authors: "AUTHORS"
  }.freeze

  def initialize(port)
    @port = port

    # Initialize controllers and routes
    @auth_controller = AuthController.new
    @product_controller = ProductController.new

    @auth_route = AuthRoute.new(@auth_controller)
    @product_route = ProductRoute.new(@product_controller)

    LOG.info "Application started on port #{@port}..."
  end

  def call(env)
    begin
      env["PATH_INFO"] = normalize_path(env["PATH_INFO"])

      return serve_static_file(:openapi, env) if env["PATH_INFO"] == "/openapi.yml"
      return serve_static_file(:authors, env) if env["PATH_INFO"] == "/AUTHORS"

      response = @auth_route.call(env)
      return response if response

      response = @product_route.call(env)
      return response if response

      LOG.warn "404 Not Found: #{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
      [404, { "Content-Type" => "application/json" }, [{ error: "Not found" }.to_json]]
    rescue StandardError => e
      LOG.error "Unhandled exception: #{e.message}\n#{e.backtrace.join("\n")}"
      [500, { "Content-Type" => "application/json" }, [{ error: "Internal server error" }.to_json]]
    end
  end

  private

  def normalize_path(path)
    path == "/" ? path : path.chomp("/")
  end

  def serve_static_file(type, env)
    file_path = STATIC_FILES[type]
    if File.exist?(file_path)
      LOG.info "Serving static file: #{file_path}"
      [
        200,
        { "Content-Type" => "text/plain", "Cache-Control" => "no-store" },
        [File.read(file_path)]
      ]
    else
      LOG.error "File not found: #{file_path}"
      [404, { "Content-Type" => "text/plain" }, ["File not found"]]
    end
  end
end
