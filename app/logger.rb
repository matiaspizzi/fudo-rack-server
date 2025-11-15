require 'logger'

$stdout.sync = true
LOG = Logger.new($stdout)
LOG.level = Logger::INFO
LOG.progname = "RubyHTTPServer"