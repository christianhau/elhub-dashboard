require 'net/http'
require 'json'
require 'uri'

SCHEDULER.every '1h', :first_in => 0 do |job|
    uri = URI("https://sulten.81549300.xyz")
    response = Net::HTTP.get(uri)
    today = JSON.parse(response)["idag"]

    unless today.kind_of?(Array)
      today = [today]
    end

    dishes = today.join('<br>')

    send_event('lunch', { text: dishes })
end