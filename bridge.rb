module Hue

  class Bridge
    attr_accessor :light_id

    def initialize(light_num)
      self.light_id = light_num.to_s
    end

    def self.uri(*args)
      URI [BASE, UUID, args].flatten.reject{|x| x.to_s.strip == ''}.join('/')
    end

    def self.status
      JSON.parse Net::HTTP.get(Bridge.uri)
    end

    def self.lights
      status['lights']
    end

    def self.identities
      Hash[lights.map{|k, v| [k, v['name']] }]
    end

    def self.bulbs
      @bulbs ||= lights.keys.map{|b| Bulb.new b}
    end

    def self.reload
      @bulbs = nil
      self
    end

    def display(response = nil)
      if response and response.code.to_s != '200'
        puts "Response #{response.code} #{response.message}: #{JSON.parse(response.body).first}"
      end
    end

    def update_state(settings)
      update Bridge.uri('lights', light_id, 'state'), settings
    end

    def update_base(settings)
      update Bridge.uri('lights', light_id), settings
    end

    def update(url, settings = {})
      request = Net::HTTP::Put.new(url.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = settings.to_json
      display Net::HTTP.new(url.host, url.port).start {|http| http.request(request) }
    end

  end

end # Hue