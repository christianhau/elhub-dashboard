require 'net/http'
require 'json'
require 'time'
require 'open-uri'
require 'cgi'

yamlFile = "./conf/jira_issuecount.yaml"
if File.exist?(yamlFile)
  JIRA_OPENISSUES_CONFIG = YAML.load(File.new(yamlFile, "r").read)
else
  JIRA_OPENISSUES_CONFIG = {
    jira_url: "",
    username:  "",
    password: "",
    issuecount_mapping: {
      'filterX' => "filter=1234"
    }
  }
end

def getNumberOfIssues(url, username, password, jqlString)
  jql = CGI.escape(jqlString)
  uri = URI.parse("#{url}/rest/api/2/search?jql=#{jql}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == 'https'
  request = Net::HTTP::Get.new(uri.request_uri)
  if !username.nil? && !username.empty?
    request.basic_auth(username, password)
  end
  JSON.parse(http.request(request).body)["total"]
end

JIRA_OPENISSUES_CONFIG[:issuecount_mapping].each do |mappingName, filter|
  SCHEDULER.every '1m', :first_in => 0 do
    total = getNumberOfIssues(JIRA_OPENISSUES_CONFIG[:jira_url], JIRA_OPENISSUES_CONFIG[:username], JIRA_OPENISSUES_CONFIG[:password], filter)
    send_event(mappingName, {current: total})
  end
end
