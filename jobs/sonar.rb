require 'net/http'
require 'json'
require 'openssl'
require 'uri'

config_path = File.expand_path(File.join(File.dirname(__FILE__), "sonar.cfg"))
puts "Sonar widget configuration: " + config_path
configuration = Hash[File.read(config_path).scan(/(\S+)\s*=\s*"([^"]+)/)]

# Required config
server = "#{configuration['server']}".strip
key = "#{configuration['key']}".strip
id = "#{configuration['widget_id']}".strip
interval = "#{configuration['interval']}".strip
metrics = "#{configuration['metrics']}".strip

# Optional config for secured instances
username = "#{configuration['username']}".strip
password = "#{configuration['password']}"

if id.empty?
    abort("MISSING widget id configuration!")
end
if interval.empty?
    abort("MISSING interval configuration!")
end
if server.empty?
    abort("MISSING server configuration!")
end
if key.empty?
    abort("MISSING key configuration!")
end
if metrics.empty?
    abort("MISSING metrics configuration!")
end

def get_val(json, key)
  returnval = ''
  json['msr'].find do |item|
    returnval = item['val']
    key == item['key']
  end
  returnval
end

SCHEDULER.every interval, :first_in => 0 do |job|

    res = nil
    uri = URI("#{server}/api/resources?resource=#{key}&metrics=#{metrics}")

    # if no username is provided, assume sonar server is unsecured
    if username.empty?
        res = Net::HTTP.get(uri)

    else
        Net::HTTP.start(uri.host, uri.port,
          :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

          request = Net::HTTP::Get.new uri.request_uri
          request.basic_auth username, password

          res = http.request request
        end
    end

    # Order of display is dictated by order of metrics in sonar.cfg
    metricsArray = metrics.split(',')
    hashArray = []
    metricsArray.each { |x| hashArray.push({:label => x.gsub("_", " "), :value => get_val(JSON[res.body][0], x) }) }

    send_event(id, { items: hashArray })
end