class Multiplexer
    var values, old_values
    var address_pins, common_pin
    var tolerance
    var topic

    def init()
        self.values  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        self.old_values  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        self.address_pins = [-1,-1,-1,-1]
        self.tolerance = 0
        self.topic = tasmota.cmd("Topic")["Topic"]

    end

    def set_common_analog_input_pin(pin_common_adc)
        import string
        var gpio_config = tasmota.cmd("GPIO")
        if (!gpio_config[string.format("GPIO%i",pin_common_adc)].contains("4704"))
            tasmota.cmd(string.format("GPIO%i 4704", pin_common_adc))
        end
    end

    def set_address_pins(a0, a1, a2, a3)
        self.address_pins = [a0, a1, a2, a3]
        for i: 0 .. 3
            gpio.pin_mode(self.address_pins[i], gpio.OUTPUT)
        end
    end

    def set_tolerance(tolerance)
        self.tolerance = tolerance
    end

    def write_out_address (address)
        for i: 0 .. 3
            var bit = (address >> i) & 0x01
            gpio.digital_write(self.address_pins[i], bit)
        end
    end

    def every_second()
        var is_dirty = false
        import json
        import math
        import mqtt
        import string
        for address: 0 .. 15
            self.write_out_address(address)
            self.values[address] = tasmota.cmd("status 10")['StatusSNS']['ANALOG']['A1']
            if (math.abs(self.values[address] - self.old_values[address]) > self.tolerance)
                is_dirty = true
            end
        end
        if (is_dirty)
            mqtt.publish("tele/" + self.topic +"/MUX", json.dump(self.values))
        end
        for i: 0 .. 15
            self.old_values[i] = self.values[i]
        end
    end
end

#var mux = Multiplexer()
#mux.set_address_pins(16,17,5,18)
#mux.set_common_analog_input_pin(34)
#tasmota.add_driver(mux)