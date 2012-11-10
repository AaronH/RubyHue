module Hue

  class Bulb

    attr_accessor :id, :stash, :options

    def initialize(light_num, options = {})
      self.id       = light_num
      self.options  = options
    end

    def status
      JSON.parse Net::HTTP.get(Bridge.uri('lights', id))
    end

    def states
      status['state']
    end

    def [](item)
      states[item.to_s]
    end

    def update(settings = {})
      puts @options.merge(settings).inspect
      Bridge.update Bridge.uri('lights', id, 'state'), @options.merge(settings)
    end

    def name
      status['name']
    end

    def name=(_name)
      Bridge.update uri('lights', light_id), name: _name
    end

    def on?
      self[:on]
    end

    def off?
      !on?
    end

    def on
      update on: true
      on?
    end

    def off
      update on: false
      off?
    end

    def brightness
      self[:bri]
    end

    def brightness=(bri)
      update bri: bri
      brightness
    end

    def hue
      self[:hue]
    end

    def hue=(_hue)
      _hue = (_hue * (65536.0 / 360)).to_i
      update hue: _hue
      hue
    end

    def sat
      self[:sat]
    end

    def sat=(_sat)
      update sat: _sat
      sat
    end

    def transition_time
      # transition time in seconds
      (options[:transitiontime] || 1).to_f / 10
    end

    def transition_time=(time)
      # transition time in seconds
      self.options[:transitiontime] = (time * 10).to_i
    end

    def colortemp
      self[:ct]
    end

    def colortemp=(_ct)
      update ct: _ct
      colortemp
    end

    def colormode
      self[:colormode]
    end

    def blinking?
      !!(self['alert'] =~ /l?select/)
    end

    def blink(start = true)
      update(alert: (start ? 'lselect' : 'none'))
    end

    def solid
      update alert: 'none'
    end

    def flash
      update alert: 'select'
      update alert: 'none'
    end

    def settings
      state = states
      options.merge case state['colormode']
                    when 'ct'
                      {'ct' => state['ct']}
                    when 'xy'
                      {'xy' => state['xy']}
                    when 'hs'
                      {'hue' => state['hue'], 'sat' => state['sat']}
                    end.merge('on' => state['on'], 'bri' => state['bri'])
    end
    alias :color :settings

    def stash!
      self.stash ||= settings
    end

    def restore!
      if stash
        update stash
        unstash!
      end
    end

    def unstash!
      self.stash = nil
    end

    def candle(repeat = 15)
      # 0-65536 for hue, 182 per deg. Ideal 30-60 deg (5460-10920)
      stash!
      on if off?

      repeat.times do
        hue = ((rand * 5460) + 5460).to_i
        sat = rand(64) + 170
        bri = rand(32) + 16

        delay = (rand * 0.5) + (@delay ||= 0)
        update(hue: hue, sat: sat, bri: bri, transitiontime: (delay * 10).to_i)
        sleep delay
      end
      restore!
    end
  end

end # Hue