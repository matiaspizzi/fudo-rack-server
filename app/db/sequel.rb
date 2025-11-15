require "sequel"
require "logger"
require "dotenv/load"

DB = Sequel.connect(
  adapter: 'postgres',
  user: ENV['DB_USER'],
  password: ENV['DB_PASSWORD'],
  host: ENV['DB_HOST'],
  database: ENV['DB_NAME'],
  port: ENV['DB_PORT'],
  sslmode: 'require'
)

DB.loggers << Logger.new($stdout)