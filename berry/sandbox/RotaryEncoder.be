    class RotaryEncoder
        static var CW = 1
        static var  CCW = 2
        var a_pin, b_pin
        var fast_loop_closure
        var old_state
        var on_tick_cb
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

            self.topic = tasmota.cmd("Topic")["Topic"]
            
            tasmota.add_fast_loop(/-> self.tick()   )
        end

        def set_on_tick_callback (cb)
            self.on_tick_cb = cb
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
                

                #TODO: ha tul lassan kell tekerni, hogy erzekeljen, akkor meg ugy lehet optimalizalni a kodot, hogy nem a teljes minta azonossagat ellenorzni,
                #hanem csak a rising (1) es falling (2) edget egymas utan kovetkezik e a pufferben. Bonyolultabb muvelet,de hibaturobb.
                if (self.knob_signal_window == [1,0,2,3])
                    self.knob_step_counter+=1
                    if (type(self.on_tick_cb)== "function")
                        self.on_tick_cb(self.CW, self.knob_step_counter)
                    end
                end
                
                if (self.knob_signal_window == [2,0,1,3])
                    self.knob_step_counter-=1
                    if (type(self.on_tick_cb)== "function")
                        self.on_tick_cb(self.CCW, self.knob_step_counter)
                    end
                end
                self.old_state = this_state
            end

        end


    end

    var encoder = RotaryEncoder(22,23)
    var cb = def(dir, cnt) print(cnt) end
    tasmota.add_driver(encoder)
    #encoder.set_on_tick_callback( cb )