require 'httparty'
require 'digest'
require 'json'

BASE = 'http://192.168.0.5/api'
UUID = Digest::MD5::hexdigest('ruby-hue')

response = HTTParty.get("#{BASE}/#{UUID}/lights")
if response.body =~ /unauthorized/
  post = {:username => UUID, :devicetype => "huebert"}
  response = HTTParty.post(BASE, :body => post.to_json)
  if response.body =~ /link button not pressed/
    puts "Push the link button on the controller and run this script again."
  end
end

load 'hue.rb'
Hue::Bridge.identities.each_with_index do |name, index|
  hue = rand(65535)
  sat = 255
  brightness = 255
  puts "Setting #{name} to hue #{hue}, saturation #{sat} and brightness #{brightness}"
  bulb = Hue::Bulb.new(index)
  bulb.update(:hue => hue, :sat => sat, :brightness => brightness)
end
