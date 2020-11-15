class App
  require 'byebug'
  require './lib/network_checks'

  HEADERS = { "Content-Type" => "text/html" }

  def call(env)
    case env['PATH_INFO']
    when '/speedtest' then speedtest
    when '/fast' then fast
    when '/ping_8' then ping_8
    when '/ping_D' then ping_D
    when '/ping_I' then ping_I
    else
      index
    end
  end

  def index
    @clients = NetworkChecks.list_wifi_clients

    body = ERB.new(File.read('index.html.erb')).result(binding())

    respond(body)
  end

  def respond(body)
    [200, HEADERS, [body]]
  end

  def speedtest
    output = `bins/speedtest-cli --simple --share`

    body = output.split("\n").map { |l| l.match(/Share results: (.*)\z/)&.captures&.first }.compact.first

    respond('<img src="' + body + '"/>')
  end

  def fast
    output = `bins/fast_linux`
    respond output.split("\r").last.squish.gsub(/\A.*->/, '->')
  end

  def ping_8
    respond `ping -c 5 8.8.8.8 -w 5000`.gsub("\n", "<br>")
  end

  def ping_D
    respond `ping -c 5 digitalocean.com -w 5000`.gsub("\n", "<br>")
  end

  def ping_I
    body = NetworkChecks::INTERNAL_IPS.map do |name, ip|
      output = "<h3>#{name}</h3><br>"
      output + `ping -c 5 #{ip} -w 5000`.gsub("\n", "<br>")
    end.join("<br>")

    respond body
  end
end

use Rack::Static, :urls => ["/assets"]
run App.new
