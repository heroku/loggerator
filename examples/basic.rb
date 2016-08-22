require 'webrick'
require 'logger'
require_relative '../lib/loggerator'

class BasicApp < WEBrick::HTTPServlet::AbstractServlet
  include Loggerator

  def do_GET(req, res)
    log_context app: :basic do
      status = 200

      log status: status, method: req.request_method, path: req.path do
        res['content-type'] = 'text/html'
        res.body = '<h1>Hello Loggerator!</h1>'
        res.status = status
      end
    end
  end
end

httpd = WEBrick::HTTPServer.new(
  :Port         => 3000,

  # silence default logger
  :Logger       => Logger.new('/dev/null'),
  :AccessLog    => [ ]
)

httpd.mount('/', BasicApp)

trap(:INT) { httpd.shutdown }
httpd.start
