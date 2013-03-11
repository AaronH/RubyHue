BASE = 'http://192.168.0.5/api' unless defined?(BASE)
UUID = Digest::MD5::hexdigest('ruby-hue') unless defined?(UUID)

require 'net/http'
require 'json'
require 'matrix.rb'

RGB_MATRIX = Matrix[[3.233358361244897, -1.5262682428425947, 0.27916711262124544], [-0.8268442148395835, 2.466767560486707, 0.3323241608108406], [0.12942207487871885, 0.19839858329512317, 2.0280912276039635]]

load 'bridge.rb'
load 'bulb.rb'
