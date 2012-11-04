module Hue

  class Bulb

    attr_accessor :id, :hub, :stash

    def initialize(light_num)
      self.id   = light_num
      self.hub  = Bridge.new light_num
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
      hub.update_state settings
    end

    def name
      status['name']
    end

    def name=(_name)
      hub.update_base name: _name
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
      self['alert'] =~ /l?select/
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
      case state['colormode']
      when 'ct'
        {'ct' => state['ct']}
      when 'xy'
        {'xy' => state['xy']}
      when 'hs'
        {'hue' => state['hue'], 'sat' => state['sat']}
      end.merge('on' => state['on'], 'bri' => state['bri'])
    end

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
        update hue: hue, sat: sat, bri: bri

        # delay = (rand * 0.5) + (@delay ||= 0)
        # sleep delay
      end
      restore!
    end
  end

end # Hue