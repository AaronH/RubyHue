RubyHue
================

This is a very early attempt to create a Ruby library for controlling the [Philips Hue](http://www.meethue.com) lighting system. The API has not yet been released, but there are [several](http://www.nerdblog.com/2012/10/a-day-with-philips-hue.html) [people](http://rsmck.co.uk/hue) working to figure it out.

# WARNING
All of this is very experimental and could permanently damage your awesome (but ridiculously expensive) lightbulbs. As such, exercise extreme caution.

## Getting Started
You can get a [great overview](http://rsmck.co.uk/hue) of the options and limitations of the lights from Ross McKillop.

You will need to find the IP address of your bridge unit and also generate a unique ID (UUID works great) for your controlling application and add them to the top of the `hue.rb` file.

You will need to use this information to register your app with the controller. This library does not do that at this time, so you will need to manually do that. I suggest following the *Registering Your Application* section of [Ross's overview](http://rsmck.co.uk/hue).

## Usage
To begin using, fire up the irb console and load the `hue.rb` file.

```ruby
>> load 'hue.rb'
=> true
```

You can see all of the lights attached to your controller by querying the bridge.

```ruby
>> Hue::Bridge.identities
=> {"1"=>"Master Bedroom Dresser", "2"=>"Wife Bedside", "3"=>"Bedside (front)", "4"=>"Bedside (back)", "5"=>"Family Room Desk", "6"=>"Family Room", "7"=>"Living Room Square"}
```

If you know the ID number of a particular lamp, you can access it directly.

```ruby
>> b = Hue::Bulb.new(5)
=> #<Hue::Bulb:0x007fe35a3586b8 @id=5, @hub=#<Hue::Bridge:0x007fe35a358690 @light_id="5">>

# on/off
>> b.on?
=> false

>> b.on
=> true

>> b.on?
=> true

# settings
>> b.settings
=> {"ct"=>343, "on"=>true, "bri"=>240}

>> b.brightness = 128
=> 128

>> b.update hue: 45000, sat: 180
=> true

>> b.settings
=> {"hue"=>45000, "sat"=>180, "on"=>true, "bri"=>128}

# blinking
>> b.blinking?
=> false

>> b.blink
=> nil

>> b.blinking?
=> true

>> b.blink false
=> nil

>> b.blinking?
=> false
```

## Experimental
There is an experimental mode that attempts to simulate a candle flicker. This defaults to only flickering 15 times as it's really not the way the bridge or bulbs were designed to work. Additionally, this operates on the main thread so you really can't do anything else while it's running.

```ruby
>> b.candle
=> nil
```

The candle makes use of temporarily stashing the lamp's current settings before it starts and then restoring them upon completion. You can use this yourself with the `stash` and `restore` commands.

## Going Forward
There is still a lot of work to be done figuring out the various timer options of the hub, etc. Hopefully, the official API will be released in the near future and expose even more goodies that we're unaware of.