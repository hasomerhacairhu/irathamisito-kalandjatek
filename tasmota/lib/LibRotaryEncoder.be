class RotaryEncoder
    static var CW = 1
    static var  CCW = 2
    var a_pin, b_pin
    var fast_loop_closure
    var old_state
    var knob_signal_window, knob_step_counter, old_knob_step_counter
    var topic
    

    def init(a_pin, b_pin)
        import json

        self.a_pin = a_pin
        self.b_pin = b_pin
        self.old_state = 0
        gpio.pin_mode(self.a_pin, gpio.INPUT)
        gpio.pin_mode(self.b_pin, gpio.INPUT)

        self.knob_signal_window = [0,0,0,0]
        self.knob_step_counter = 0
        self.old_knob_step_counter = 0
        
        tasmota.add_fast_loop(/-> self.tick())
    end

    def set_topic(topic)
        self.topic = topic
    end

    def every_second()
        if (self.old_knob_step_counter != self.knob_step_counter)
            import mqtt
            import json
            var difference = self.knob_step_counter - self.old_knob_step_counter
            var payload = {"current_step": self.knob_step_counter, "difference": difference, "direction": difference > 0 ? "CW" : "CCW" }
            mqtt.publish("tele/" + self.topic +"/ROTARY", json.dump(payload))
        end

        self.old_knob_step_counter = self.knob_step_counter
    end

    def tick()
        var a_sig = gpio.digital_read(self.a_pin)
        var b_sig = gpio.digital_read(self.b_pin)
        var this_state = a_sig | (b_sig << 1)

        if (self.old_state != this_state)
            self.knob_signal_window.pop(0)
            self.knob_signal_window.push(this_state)

            # Check for clockwise rotation (starts with 1, needs 0 before 2)
            if self.knob_signal_window[0] == 1
                var found_zero = false
                for i: 1..3
                    if self.knob_signal_window[i] == 0
                        found_zero = true
                    elif self.knob_signal_window[i] == 2 && found_zero
                        self.knob_step_counter += 1
                        break
                    end
                end
            end

            # Check for counter-clockwise rotation (starts with 2, needs 0 before 1)
            if self.knob_signal_window[0] == 2
                var found_zero = false
                for i: 1..3
                    if self.knob_signal_window[i] == 0
                        found_zero = true
                    elif self.knob_signal_window[i] == 1 && found_zero
                        self.knob_step_counter -= 1
                        break
                    end
                end
            end

            self.old_state = this_state
        end
    end
end