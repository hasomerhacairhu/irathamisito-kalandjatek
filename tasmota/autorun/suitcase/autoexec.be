load("lib/RotaryEncoder.be")

var encoder = RotaryEncoder(22,23)
tasmota.add_driver(encoder)
#var cb = def(dir, cnt) print(cnt) end
#encoder.set_on_tick_callback( cb )