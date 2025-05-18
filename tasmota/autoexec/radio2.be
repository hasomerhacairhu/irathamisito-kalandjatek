tasmota.cmd("SetOption114 1")
tasmota.cmd("SwitchMode0 16")
tasmota.cmd("SerialLog 3")

class StepperDriver
    def every_second()
        import mqtt
        import string
    
        var MIN_BYTES    = 50      # we need at least this many before processing
        var PAUSE_MS     = 10      # how long to wait between checks
        var MAX_ATTEMPTS = 3       # total retries if the buffer is short
    
        for attempt: 1 .. MAX_ATTEMPTS
            var avail = self.ser.available()
    
            # 1. nothing in the buffer → give up immediately
            if avail == 0
                return
            end
    
            # 2. some data but not enough → wait a bit and retry
            if avail < MIN_BYTES
                tasmota.delay(PAUSE_MS)   # blocks ≤ 10 ms; safe for three loops
                tasmota.log(string.format("Broken buffer. Let's wait for more incoming bytes from motor driver. Retry - %i. attempt.", attempt))
                continue
            end
    
            # 3. we have ≥ 60 bytes → read and publish once, then exit
            var msg = self.ser.read()
            if msg != nil
                mqtt.publish("tele/" + self.topic + "/stepper", msg.asstring())
            end
            return
        end
    
        # if the loop finishes without returning, we timed-out after 3 tries
    end
    


    var ser, topic
    def stepper_command(cmd, idx, payload, payload_json)
        payload += "\n"
        self.ser.write(bytes().fromstring(payload))
        tasmota.resp_cmnd_done()
    end

    def go_home()
        self.ser.write(bytes().fromstring("HOMEALL\n"))
        log("Automatic homing sequence started.")
    end

    def init()
        self.topic = tasmota.cmd("Topic")["Topic"]
        self.ser = serial(16, 17, 9600, serial.SERIAL_8N1)
        tasmota.add_cmd('stepper', /cmd, idx, payload, payload_json-> self.stepper_command(cmd, idx, payload, payload_json))
        tasmota.set_timer(15000, /-> self.go_home())
    end
end

tasmota.add_driver(StepperDriver())