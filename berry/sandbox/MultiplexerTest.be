class Multiplexer
    var values, old_values, mapped_values, map
    var address_pins, common_pin
    var tolerance
    var topic, log_level
    
    # Distributed iteration globals. 
    var mux_iteration_counter, is_mux_dirty


    def init()
        self.values  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        self.old_values  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        self.mapped_values  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        self.map = [
            [176, 407, 1],
            [408, 638, 2],
            [639, 870, 3],
            [871, 1102, 4],
            [1103, 1333, 5],
            [1334, 1565, 6],
            [1566, 1796, 7],
            [1797, 2028, 8],
            [2029, 2260, 9],
            [2261, 2491, 10],
            [2492, 2723, 11],
            [2724, 2955, 12],
            [2956, 3186, 13],
            [3187, 3418, 14],
            [3419, 3649, 15],
            [3650, 4092, 0],
            # [3650, 3881, 0],
            # [3882, 4092, 0],
        ]
        self.address_pins = [-1,-1,-1,-1]
        self.tolerance = 10
        self.topic = tasmota.cmd("Topic")["Topic"]
        self.log_level = tasmota.cmd("WebLog")["WebLog"]
        self.mux_iteration_counter = 0
        self.is_mux_dirty = false

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

    def map_raw_value(raw_value)
        for range: self.map
            log(range)
            var from = range[0]
            var to = range[1]
            var value = range[2]
            if (raw_value >= from && raw_value <= to)
                return value
            end
        end
        return -1
    end


    def read()
        import json
        import math

        # Distributed iteration of 16 letters. Runs every 100ms
        var address = self.mux_iteration_counter
        self.write_out_address(address)
        self.values[address] = json.load(tasmota.read_sensors())["ANALOG"]["A1"]
        self.mapped_values[address] = self.map_raw_value(self.values[address])
        if (math.abs(self.values[address] - self.old_values[address]) > self.tolerance)
            self.is_mux_dirty = true
        end


        if (self.mux_iteration_counter == 15)
            var return_values = [self.is_mux_dirty, self.mapped_values, self.values]
            for i: 0 .. 15
                self.old_values[i] = self.values[i]
            end
            log(return_values, 4)
            self.mux_iteration_counter = 0
            self.is_mux_dirty = false
            return return_values        
        end
        self.mux_iteration_counter += 1
        return false
    end

    def every_100ms()
        var mux = self.read()
        if (mux)
            import json
            import mqtt
            var is_dirty = mux[0]
            var mapped_values = mux[1]


            if (is_dirty)
                mqtt.publish("tele/" + self.topic +"/MUX", json.dump(mapped_values))
            end
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
tasmota.add_driver(mux)