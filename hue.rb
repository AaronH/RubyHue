BASE    = 'http://IP_ADDRESS_OF_YOUR_BRIDGE/api'
UUID    = 'UNIQUE_IDENTIFIER'

require 'net/http'
require 'json'
require 'matrix.rb'

RGB_MATRIX = Matrix[[3.233358361244897, -1.5262682428425947, 0.27916711262124544], [-0.8268442148395835, 2.466767560486707, 0.3323241608108406], [0.12942207487871885, 0.19839858329512317, 2.0280912276039635]]

load File.expand_path('../bridge.rb', __FILE__)
load File.expand_path('../bulb.rb', __FILE__)