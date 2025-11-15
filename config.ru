require "bundler/setup"
require "dotenv/load"

require_relative "./app/app"
require_relative "./app/middlewares/jwt_middleware"
require_relative "./app/middlewares/gzip_middleware"
require_relative "./app/logger"

$stdout.sync = true

use GzipMiddleware
use JwtMiddleware

port = ENV['PORT'] || 9292

run App.new(port)
