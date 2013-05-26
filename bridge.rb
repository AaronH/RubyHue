module Hue

  class Bridge
    attr_accessor :light_id

    def self.shared
      @shared ||= Bridge.new
    end

    def self.method_missing(method, *args, &block)
      if args.empty?
        self.shared.send method
      else
        self.shared.send method, *args
      end
    end

    def initialize(light_num = nil)
      self.light_id = light_num.to_s
    end

    def uri(*args)
      URI [BASE, UUID, args].flatten.reject{|x| x.to_s.strip == ''}.join('/')
    end

    def status
      JSON.parse Net::HTTP.get(Bridge.shared.uri)
    end

    def lights
      status['lights']
    end

    def identities
      Hash[lights.map{|k, v| [k, v['name']] }]
    end

    def bulbs
      @bulbs ||= lights.keys.map{|b| Bulb.new b}
    end

    def reload
      @bulbs = nil
      self
    end

    def schedules
      status['schedules']
    end

    def remove_schedule(schedule_id)
      delete uri('schedules', schedule_id)
      puts "Removed schedule #{schedule_id}"
    end

    def remove_all_schedules
      ids = schedules.keys.map(&:to_i).sort.reverse
      puts "Removing #{ids.size} schedule#{'s' if ids.size != 1}..."
      ids.each{|x| remove_schedule x}
    end

    def display(response = nil, options = {})
      if response and response.code.to_s != '200'
        puts "Response #{response.code} #{response.message}: #{JSON.parse(response.body).first}"
        false
      else
        if options[:parse]
          JSON.parse(response.body)
        else
          true
        end
      end
    end

    def update_state(settings)
      update uri('lights', light_id, 'state'), settings if light_id
    end

    def update_base(settings)
      update uri('lights', light_id), settings if light_id
    end

    def update(*args)
      settings = args.pop
      url = parse_uri(*args)
      request = Net::HTTP::Put.new(url.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = settings.to_json
      display Net::HTTP.new(url.host, url.port).start {|http| http.request(request) }
    end
    alias :put :update

    def delete(*args)
      url = parse_uri(*args)
      request = Net::HTTP::Delete.new(url.request_uri, initheader = {'Content-Type' =>'application/json'})
      display Net::HTTP.new(url.host, url.port).start{|http| http.request(request)}
    end

    def get(*args)
      url = parse_uri(*args)
      request = Net::HTTP::Get.new(url.request_uri, initheader = {'Content-Type' =>'application/json'})
      display Net::HTTP.new(url.host, url.port).start{|http| http.request(request)}, parse: true
    end

    def post(*args)
      settings = args.pop
      url = parse_uri(*args)
      request = Net::HTTP::Post.new(url.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = settings.to_json
      display Net::HTTP.new(url.host, url.port).start {|http| http.request(request) }
    end

    def parse_uri(*args)
      [*args].first.is_a?(URI) ? [*args].first : uri(args)
    end

    def groups
      get :groups
    end

    def group(_id)
      get :groups, _id
    end

  end

end # Hue
