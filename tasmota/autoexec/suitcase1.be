var encoder = RotaryEncoder(22,23)
tasmota.add_driver(encoder)


tasmota.cmd("SetOption43 100")
tasmota.cmd("SetOption114 1")
tasmota.cmd("I2SGain 30")
tasmota.cmd("SwitchMode0 16")

#Borondnel van egy rule, nem tudom melyik vezerlohoz tartozik.