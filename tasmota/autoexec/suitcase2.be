tasmota.cmd("SetOption43 100")
tasmota.cmd("SetOption114 1")
tasmota.cmd("SwitchMode0 16")

#led mux rotary

#A Tasmota konfiguracioban ne legyen beallitva a gyari rotary driver

var PIN_ROTARY_A = 17
var PIN_ROTARY_B = 16
var PIN_MUX_ADDR_0 = 15
var PIN_MUX_ADDR_1 = 14
var PIN_MUX_ADDR_2 = 12
var PIN_MUX_ADDR_3 = 13
var PIN_MUX_COM = 33

var topic = tasmota.cmd("Topic")["Topic"]

var encoder = RotaryEncoder(PIN_ROTARY_A,PIN_ROTARY_B)
encoder.set_topic(topic)
tasmota.add_driver(encoder)

var mux = Multiplexer()


var character_maps = {
    "SUITCASE1_2": ["_", "M", "E", "G", "Y", "R", "I", "J", "Ó", "Z", "S", "F", "#", "#", "#", "#"],
    "SUITCASE2_2": ["_", "K", "O", "V", "Á", "C", "S", "G", "Y", "Ö", "R", "#", "#", "#", "#", "#"],
    "SUITCASE3_2": ["_", "R", "A", "P", "O", "S", "T", "I", "B", "#", "#", "#", "#", "#", "#", "#"],
    "SUITCASE4_2": ["_", "B", "A", "K", "O", "S", "N", "D", "R", "#", "#", "#", "#", "#", "#", "#"],
    "SUITCASE5_2": ["_", "B", "A", "L", "O", "G", "H", "É", "V", "#", "#", "#", "#", "#", "#", "#"],
}

mux.set_address_pins(PIN_MUX_ADDR_0,PIN_MUX_ADDR_1,PIN_MUX_ADDR_2,PIN_MUX_ADDR_3)
mux.set_common_analog_input_pin(PIN_MUX_COM)
mux.set_topic(topic)
mux.set_character_map(character_maps[topic])
mux.set_tolerance(15)
tasmota.add_driver(mux)