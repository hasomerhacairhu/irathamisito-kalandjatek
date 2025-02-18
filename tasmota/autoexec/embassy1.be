var delay_config = def()
    tasmota.cmd("I2SGain 30")
    tasmota.cmd("SetOption114 1")
    tasmota.cmd("SwitchMode0 15")
end

tasmota.set_timer(10000, delay_config)
