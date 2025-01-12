tasmota.cmd("SetOption43 100")
tasmota.cmd("SetOption114 1")
tasmota.cmd("SwitchMode0 16")

#led mux rotary

#A Tasmota konfiguracioban ne legyen beallitva a gyari rotary driver

var PIN_ROTARY_A = 0
var PIN_ROTARY_B = 1
var PIN_MUX_ADDR_0 = 15
var PIN_MUX_ADDR_1 = 14
var PIN_MUX_ADDR_2 = 12
var PIN_MUX_ADDR_3 = 13
var PIN_MUX_COM = 33

var encoder = RotaryEncoder(PIN_ROTARY_A,PIN_ROTARY_B)
tasmota.add_driver(encoder)

var mux = Multiplexer()
mux.set_address_pins(PIN_MUX_ADDR_0,PIN_MUX_ADDR_1,PIN_MUX_ADDR_2,PIN_MUX_ADDR_3)
mux.set_common_analog_input_pin(PIN_MUX_COM)
tasmota.add_driver(mux)