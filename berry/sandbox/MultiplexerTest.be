class Multiplexer
    var values, old_values
    var address_pins, common_pin
    var tolerance
    var topic

    def init()
        self.values  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        self.old_values  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        # self.is_dirty = false;
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
        # gpio.pin_mode(a0, gpio.OUTPUT)
        # gpio.pin_mode(a1, gpio.OUTPUT)
        # gpio.pin_mode(a2, gpio.OUTPUT)
        # gpio.pin_mode(a3, gpio.OUTPUT)
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

    def read()
        import json
        import math
        import string
        var is_dirty = false;
        for address: 0 .. 15
            self.write_out_address(address)
            self.values[address] = json.load(tasmota.read_sensors())["ANALOG"]["A1"]
            if (math.abs(self.values[address] - self.old_values[address]) > self.tolerance)
                is_dirty = true
            end
        end
        var return_values = [is_dirty, self.values]
        print(self.values)
        for i: 0 .. 15
            self.old_values[i] = self.values[i]
        end
        return return_values
    end

    def every_second()
        import json
        import mqtt
        var mux = self.read()
        var is_dirty = mux[0]
        var values = mux[1]
        print (is_dirty)
        print (values)

        if (is_dirty)
            mqtt.publish("tele/" + self.topic +"/MUX", json.dump(self.values))
        end
    end
end





var PIN_MUX_ADDR_0 = 15
var PIN_MUX_ADDR_1 = 14
var PIN_MUX_ADDR_2 = 12
var PIN_MUX_ADDR_3 = 13
var PIN_MUX_COM = 33



var mux = Multiplexer()
mux.set_address_pins(PIN_MUX_ADDR_0,PIN_MUX_ADDR_1,PIN_MUX_ADDR_2,PIN_MUX_ADDR_3)
mux.set_common_analog_input_pin(PIN_MUX_COM)
mux.every_second()