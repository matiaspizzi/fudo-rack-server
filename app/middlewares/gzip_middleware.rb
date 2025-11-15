require "zlib"
require "stringio"

class GzipMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    if env["HTTP_ACCEPT_ENCODING"]&.include?("gzip") && compressible?(headers)
      full = body.each.inject("") { |acc, chunk| acc << chunk }
      gzipped = gzip(full)
      headers["Content-Encoding"] = "gzip"
      headers["Content-Length"] = gzipped.bytesize.to_s
      return [status, headers, [gzipped]]
    end

    [status, headers, body]
  end

  private

  def compressible?(headers)
    ct = headers["Content-Type"] || ""
    ct.start_with?("application/json") || ct.start_with?("text/")
  end

  def gzip(content)
    io = StringIO.new
    gz = Zlib::GzipWriter.new(io)
    gz.write(content)
    gz.close
    io.string
  end
end
